#  Contrato de Subasta en Solidity

Este contrato permite realizar una subasta en la blockchain. Los usuarios pueden ofertar con ETH, y el que haga la mejor oferta gana. El dueño de la subasta puede finalizarla y cobrar el monto ganador. Los que no ganan pueden retirar su dinero, descontando una comisión del 2%.

---

##  Características principales

- El **dueño** del contrato es quien lo despliega y puede finalizar la subasta o retirar comisiones.
- La subasta tiene una **duración definida en minutos**.
- Cada nueva oferta debe ser **al menos 5% mayor** que la mejor oferta anterior.
- Si alguien oferta en los últimos **10 minutos**, el tiempo se extiende automáticamente.
- Los **perdedores pueden retirar su dinero**, pero se descuenta un 2% de comisión.
- El **dueño puede retirar las comisiones acumuladas**.
- Cualquiera puede ver la lista de ofertas realizadas.

---

##  Funciones principales

###  `ofertar()`

- Enviar una oferta (ETH).
- Debe ser mayor a la oferta actual por al menos un 5%.
- Si es en los últimos 10 minutos, se extiende el tiempo.
- Registra al ofertante si es nuevo.

###  `finalizarSubasta()`

- Solo el dueño o cuando termina el tiempo.
- Marca la subasta como finalizada.
- Transfiere la mejor oferta al dueño si hubo un ganador.

###  `retirar()`

- Solo para participantes que **no ganaron**.
- Devuelve su dinero menos un 2% de comisión.

###  `retirarComisiones()`

- Solo el dueño.
- Retira todas las comisiones acumuladas por los retiros de perdedores.

###  `mostrarOfertas()`

- Devuelve una lista de direcciones y los montos ofertados.
- Sirve para mostrar quién ofertó y cuánto.

---

##  Seguridad

- Solo el dueño puede finalizar la subasta antes del tiempo o retirar comisiones.
- El contrato rechaza pagos directos (solo se puede ofertar usando `ofertar()`).
- Los ganadores no pueden retirar su oferta.

---
