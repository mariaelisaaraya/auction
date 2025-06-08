![Curso](https://img.shields.io/badge/Curso-ETH_Kipu-blue)
![Modalidad](https://img.shields.io/badge/Modalidad-Online-lightgrey)
![Developer](https://img.shields.io/badge/Developer-3lisa-purple)
![Estado](https://img.shields.io/badge/Estado-Activo-brightgreen)

# 📦 SubastaEth - Contrato Inteligente de Subasta

## 📌 Información Esencial

**Red:** Sepolia  
**Contrato:** [`0x145a1f...`](https://sepolia.etherscan.io/address/0x145a1fe17d2a7ea9079aa3e0530b7fab0e285d8a#code)  
**Propietaria:** `0x39581f1c36CfeBfB36934E583fb3e3CE92Ba6c58`  
**Transacción:** [`0x96aed1...`](https://sepolia.etherscan.io/tx/0x96aed14daa1819dbbaee461d04cbb8aa917bd9857ddf2838ae20db2127d24898)

---

## 📝 Descripción General

Contrato inteligente desarrollado para el Trabajo Práctico N.º 2 del Módulo 2, **ETH Kipu**, que implementa un sistema de subastas

---

## 🚀 Características Principales

### 📜 Reglas de la Subasta
![image](https://github.com/user-attachments/assets/93e78cb1-7d1a-455a-87dc-3d3d5c7cb700)

### 🔐 Seguridad
- Modificadores para control de acceso (`soloPropietario`)
- Validaciones exhaustivas con mensajes claros en español
- Protección contra reentrancy en transferencias

### 📢 Eventos Clave
- `NuevaOferta(address indexed ofertante, uint256 monto)`
- `SubastaFinalizada(address ganador, uint256 montoFinal)`

---

## 🛠️ Implementación Técnica

### 📦 Estructuras de Datos
```solidity
struct Puja {
    uint256 monto;
    bool reembolsado;
    bool activa;
}
```

### ⚙️ Funciones Principales
- `pujar()` - Permite realizar una oferta
- `retirarExcedente()` - Reembolso parcial durante la subasta
- `finalizarSubasta()` - Finaliza la subasta y procesa pagos
- `obtenerGanador()` - Consulta al ganador actual

---

## 🛠️ 🧠 Diagrama de Flujo 

```mermaid
graph TD
    %% Sección 1: Proceso de Puja
    A[("Inicio Subasta")] --> B{"¿Puja válida?<br/>• Monto > 0<br/>• 5% > puja actual<br/>• Subasta activa"}
    B -->|Válida| C["Registrar Puja<br/>• Actualizar puja máxima<br/>• Guardar pujador"]
    B -->|Inválida| G["Revertir Transacción<br/>• Devuelve ETH<br/>• Mensaje error"]
    
    %% Sección 2: Extensión de Tiempo
    C --> D{"¿Últimos 10 minutos?"}
    D -->|Sí| E["Extender Subasta<br/>• +10 minutos<br/>• Emitir evento"]
    D -->|No| F[Continuar Subasta]
    
    %% Sección 3: Finalización
    F --> H{"¿Tiempo finalizado?"}
    H -->|No| A1[Esperar nuevas pujas]
    H -->|Sí| I["Finalizar Subasta<br/>• Solo propietario<br/>• Bloquear cambios"]
    
    %% Sección 4: Liquidación
    I --> J["Procesar Ganador<br/>• Guardar fondos<br/>• Sin comisión"]
    I --> K["Reembolsar Perdedores<br/>• 98% del valor<br/>• 2% comisión"]
    
    %% Estilos
    style A fill:#f9f,stroke:#333
    style B fill:#bbf,stroke:#333
    style I fill:#f96,stroke:#333
    style J fill:#9f9,stroke:#333
    style K fill:#f99,stroke:#333
    classDef default font-family:serif
```
---

## 🔧 Herramientas Utilizadas
- [Remix IDE](https://remix.ethereum.org/)
- [Solidity v0.8.24](https://docs.soliditylang.org/)
- [NatSpec](https://docs.soliditylang.org/en/latest/natspec-format.html) para documentación
- [Etherscan Sepolia](https://sepolia.etherscan.io/) para verificación del contrato

---

## 🌍 Consideraciones
- Idioma: Todo el código, comentarios, eventos y documentación están redactados en español, en cumplimiento con los requisitos del Trabajo Final - Módulo 2. Se asegura coherencia semántica con los nombres solicitados

---

## 📇 Información del Proyecto
**Estudiante**: Elisa Araya  
**Curso**: ETH Kipu - Ethereum Developer Pack  
**Entrega**: Proyecto Final - Módulo 2  
**GitHub**: [arayamariaelisa](https://github.com/arayamariaelisa)
