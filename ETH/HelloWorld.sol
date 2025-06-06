// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Subasta {
    address public  dueno;
    uint256 public  inicioSubasta;
    uint256 public tiempoLimite;
    bool public finalizada;
    
    address public ganador;
    uint256 public mejorOferta;
    uint256 public comision = 2; // 2%
    uint256 public comisionesAcumuladas; // Comisiones de perdedores
    
    mapping(address => uint256) public depositos;
    address[] public oferentes;

    event NuevaOferta(address indexed ofertante, uint256 monto);
    event SubastaFinalizada(address ganador, uint256 montoGanador);
    event Reembolso(address indexed ofertante, uint256 monto);
    event ComisionesRetiradas(uint256 monto);

    modifier soloActiva() {
        require(block.timestamp < tiempoLimite, "Subasta finalizada");
        require(!finalizada, "Subasta ya finalizada");
        _;
    }

    modifier soloFinalizada() {
        require(finalizada || block.timestamp >= tiempoLimite, "Subasta activa");
        _;
    }

    modifier soloDueno() {
        require(msg.sender == dueno, "Solo el dueno puede ejecutar");
        _;
    }

    constructor(uint256 duracionMinutos) {
        dueno = msg.sender;
        inicioSubasta = block.timestamp;
        tiempoLimite = block.timestamp + duracionMinutos * 1 minutes;
    }

    function ofertar() external payable soloActiva {
        require(msg.value > 0, "Oferta debe ser mayor que 0");
        
        if (depositos[msg.sender] == 0) {
            oferentes.push(msg.sender);
        }
        
        depositos[msg.sender] += msg.value;
        uint256 ofertaActual = depositos[msg.sender];
        
        require(
            ofertaActual >= mejorOferta + (mejorOferta * 5) / 100 || mejorOferta == 0,
            "Debe superar oferta anterior en al menos 5%"
        );

        mejorOferta = ofertaActual;
        ganador = msg.sender;

        if (tiempoLimite - block.timestamp < 10 minutes) {
            tiempoLimite = block.timestamp + 10 minutes;
        }

        emit NuevaOferta(msg.sender, ofertaActual);
    }

    function finalizarSubasta() external {
        require(!finalizada, "Ya finalizada");
        require(
            msg.sender == dueno || block.timestamp >= tiempoLimite,
            "Solo dueno o tras tiempo limite"
        );
        
        finalizada = true;
        
        // Enviar el 100% del dinero del ganador al dueño (sin comisión)
        if (ganador != address(0)) {
            payable(dueno).transfer(mejorOferta);
        }
        
        emit SubastaFinalizada(ganador, mejorOferta);
    }

    function retirar() external soloFinalizada {
        require(msg.sender != ganador, "Ganador no puede retirar");
        
        uint256 monto = depositos[msg.sender];
        require(monto > 0, "Sin fondos para retirar");
        
        depositos[msg.sender] = 0;
        
        // Aplicar comisión del 2% y acumularla para el dueño
        uint256 comisionPerdedor = (monto * comision) / 100;
        uint256 reembolso = monto - comisionPerdedor;
        
        comisionesAcumuladas += comisionPerdedor;
        payable(msg.sender).transfer(reembolso);
        
        emit Reembolso(msg.sender, reembolso);
    }

    function retirarComisiones() external soloDueno {
        require(comisionesAcumuladas > 0, "No hay comisiones acumuladas");
        
        uint256 monto = comisionesAcumuladas;
        comisionesAcumuladas = 0;
        
        payable(dueno).transfer(monto);
        emit ComisionesRetiradas(monto);
    }

    function verParticipantes() external view returns (address[] memory, uint256[] memory) {
        uint256 length = oferentes.length;
        address[] memory direcciones = new address[](length);
        uint256[] memory montos = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
            direcciones[i] = oferentes[i];
            montos[i] = depositos[oferentes[i]];
        }
        
        return (direcciones, montos);
    }

    receive() external payable {
        revert("Use la funcion ofertar()");
    }
}