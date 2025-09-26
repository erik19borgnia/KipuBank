TP Final del Módulo 2 del curso de Ethereum

Este contrato es un proyecto de banco seguro, con las siguientes características:
 - Hay un límite de extracción establecido (s_extractionLimit) fijo en 10'000'000'000'000 wei. (10 billones, o 10 trillions)
 - Hay un límite de depósitos (s_bankCap) definido en el despliegue.
 - Hay un conteo de depósitos y extracciones
 - Si hay algún error, se revierte con un error personalizado
 