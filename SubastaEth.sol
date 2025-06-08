// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
/**
 * @title SubastaEth
 * @dev Contrato de subasta para Trabajo Final - Módulo 2
 * @notice Funcionalidades y se incluyen Eventos Requeridos específicos
 */
contract SubastaEth {
    address public immutable propietario;
    uint256 public finSubasta;
    uint256 public pujaMaxima;
    address public pujadorMaximo;
    bool public estaFinalizada;
    
    // @notice Comisión del 2% aplicada solo a los no ganadores al finalizar la subasta
    uint256 public constant COMISION = 2;
    // @notice Incremento mínimo del 5% requerido para superar la mejor puja actual
    uint256 public constant MINIMO_INCREMENTO = 5;
    // @notice Ventana de tiempo antes del final de la subasta para permitir extensión (10 minutos)
    uint256 public constant UMBRAL_EXTENSION = 10 minutes;
    // @notice Duración de la extensión agregada a la subasta cuando se puja dentro del umbral (10 minutos)
    uint256 public constant DURACION_EXTENSION = 10 minutes;

    // Estructura para manejo de pujas
    struct Puja {
        uint256 monto;
        bool reembolsado;
        bool activa;
    }
    
    mapping(address => Puja) public pujas;
    address[] public pujadores;
    uint256 public fondosPropietario;

    // Eventos requeridos 
    event NuevaOferta(address indexed ofertante, uint256 monto); 
    event SubastaFinalizada(address ganador, uint256 montoFinal); 
    
    // Eventos adicionales para trazabilidad
    event ReembolsoEmitido(address indexed usuario, uint256 monto);
    event SubastaExtendida(uint256 nuevoFin);
    event FondosRetirados(address indexed propietario, uint256 monto);

    modifier soloPropietario() {
        require(msg.sender == propietario, "Solo el propietario puede ejecutar esta accion");
        _;
    }

    modifier cuandoSubastaActiva() {
        require(block.timestamp < finSubasta, "La subasta ya ha finalizado");
        _;
    }

    modifier cuandoSubastaFinalizada() {
        require(block.timestamp >= finSubasta, "La subasta aun esta activa");
        _;
    }

    constructor(uint256 _duracionMinutos) {
        require(_duracionMinutos > 0 && _duracionMinutos <= 10080, "Duracion debe estar entre 1 minuto y 7 dias");
        propietario = msg.sender;
        finSubasta = block.timestamp + (_duracionMinutos * 1 minutes);
    }

    /**
     * @dev Realizar una puja en la subasta
     * @notice El monto debe ser al menos 5% mayor que la puja máxima actual
     * @notice Extiende la subasta si se realiza en el período umbral
     */
    function pujar() external payable cuandoSubastaActiva {
        require(msg.value > 0, "El monto debe ser mayor a cero");

        uint256 nuevoTotal = pujas[msg.sender].monto + msg.value;
        uint256 minimoRequerido = pujaMaxima + (pujaMaxima * MINIMO_INCREMENTO) / 100;
        
        require(nuevoTotal >= minimoRequerido || pujaMaxima == 0, 
            "La puja debe ser al menos 5% mayor que la actual");

        // Se extiende subasta si es necesario
        if (block.timestamp > finSubasta - UMBRAL_EXTENSION) {
            finSubasta += DURACION_EXTENSION;
            emit SubastaExtendida(finSubasta);
        }

        // Se registra nuevo pujador si es necesario
        if (!pujas[msg.sender].activa) {
            pujadores.push(msg.sender);
            pujas[msg.sender].activa = true;
        }

        // Se actualiza puja
        pujas[msg.sender].monto = nuevoTotal;
        
        if (nuevoTotal > pujaMaxima) {
            pujaMaxima = nuevoTotal;
            pujadorMaximo = msg.sender;
        }

        emit NuevaOferta(msg.sender, msg.value); 
    }

    /**
     * @dev Retirar excedentes no comprometidos en pujas
     * @param monto Cantidad a retirar (debe ser excedente disponible)
     */
    function retirarExcedente(uint256 monto) external cuandoSubastaActiva {
        uint256 disponible = pujas[msg.sender].monto;
        uint256 comprometido = (msg.sender == pujadorMaximo) ? pujaMaxima : 0;
        uint256 excedente = disponible - comprometido;
        
        require(excedente >= monto, "No tiene suficiente excedente disponible");
        
        pujas[msg.sender].monto -= monto;
        
        // Si retira todo, se marca como inactivo pero mantenemos en pujadores[]
        if (pujas[msg.sender].monto == 0) {
            pujas[msg.sender].activa = false;
        }

        (bool exito, ) = msg.sender.call{value: monto}("");
        require(exito, "La transferencia de Ether fallo");

        emit ReembolsoEmitido(msg.sender, monto);
    }

    /**
     * @dev Se finaliza la subasta y se procesa reembolsos
     * @notice Aplica comisión del 2% solo a no ganadores por pedido de TP
     */
    function finalizarSubasta() external soloPropietario cuandoSubastaFinalizada {
        require(!estaFinalizada, "La subasta ya fue finalizada");
        estaFinalizada = true;

        for (uint256 i = 0; i < pujadores.length; i++) {
            address pujador = pujadores[i];
            Puja storage puja = pujas[pujador];
            
            if (puja.monto > 0 && !puja.reembolsado) {
                if (pujador != pujadorMaximo) {
                    // Aplicar comisión del 2% a no ganadores
                    uint256 comision = (puja.monto * COMISION) / 100;
                    uint256 reembolso = puja.monto - comision;
                    
                    fondosPropietario += comision;
                    
                    (bool exito, ) = pujador.call{value: reembolso}("");
                    require(exito, "El reembolso de Ether fallo");
                    
                    emit ReembolsoEmitido(pujador, reembolso);
                }
                puja.reembolsado = true;
            }
        }

        emit SubastaFinalizada(pujadorMaximo, pujaMaxima);
    }

    /**
     * @dev Se retira fondos acumulados por comisiones
     */
    function retirarFondosPropietario() external soloPropietario {
        require(fondosPropietario > 0, "No hay fondos disponibles para retirar");
        
        uint256 monto = fondosPropietario;
        fondosPropietario = 0;
        
        (bool exito, ) = propietario.call{value: monto}("");
        require(exito, "La transferencia de Ether fallo");

        emit FondosRetirados(propietario, monto);
    }

    /**
     * @dev Obtener información del ganador
     */
    function obtenerGanador() external view returns (address, uint256) {
        return (pujadorMaximo, pujaMaxima);
    }

    /**
     * @dev Obtener lista de todas las pujas
     */
    function obtenerPujas() external view returns (address[] memory, uint256[] memory) {
        uint256[] memory montos = new uint256[](pujadores.length);
        for (uint256 i = 0; i < pujadores.length; i++) {
            montos[i] = pujas[pujadores[i]].monto;
        }
        return (pujadores, montos);
    }

    // Función para recibir Ether
    receive() external payable {}
}