# Modelo de Propagacion de COVID19 en Ambientes Cerrados

## Descripción
El siguiente proyecto tiene como finalidad realizar una calculadora para computar la probabilidad de contagio del virus COVID-19 estando en un ambiente cerrado. Para realizar el cálculo se toman en cuenta diferentes parámetros relacionados con la expulsión de partículas en aerosol que contienen el virus, partículas que al ser depositadas en el interior de las vías respiratorias provocan el contagio de la enfermedad del COVID-19.

Posteriormente, se utiliza la probabilidad calculada para realizar una simulación de la trasmisión del virus en un ambiente cerrado. Para la realización de la simulación se utiliza un modelo basado en agentes, este modelo a grandes razgos consiste en modelar como un objeto cada uno de los diferentes elementos que forman parte del sistema que se está analizando y se desea simular. 

Información más detallada referente a lo mencionado en esta sección se describe en el documento "covid19_agents_model_base.jl", el cual constituye un cuaderno de Pluto donde corre la simulación.

## Requerimientos
Para correr la simulación, en el archivo "covid19_agents_model_base.jl", se necesita instalar en la computadora las siguientes dependencias:
* Lenguaje de programación Julia, verión 1.4 o superior.
* Instalación de los siguientes paquetes de Julia:
  - PlutoUI
  - Random 
  - Plots
  - Agents
  - DrWatson

Cada uno de los paquetes de Julia se instalan desde el REPL de Julia (en cualquiera de los sistemas operativos), utilizando los siguientes comandos:
* using Pkg: *Manejador de paquetes de Julia*
* Pkg.activate("."): *Esta línea de comando activa un ambiente virtual en la carpeta donde se encuentra el archivo mencionado, en este caso la carpeta que constituye este repositorio, que además contiene los archivos "Manifest.toml" y "Project.toml".*
* Pkg.resolve(): *Actualiza el grafo de dependencias declarado en los archivos adicionales mencionados.*
* Pkg.instantiate(): *Instala las dependencias necesarias para correr el proyecto.*

Para que los pasos anteriores realicen la función deseada, se debe asegurar que el REPL de Julia corra desde el directorio de trabajo donde se encuentran los archivos "Manifest.toml" y "Project.toml". 

Con las dependencias instaladas y el entorno virtual activado, desde el REPL se abre el notebook de Pluto con los comandos: 
* using Pluto; Pluto.run()

## Manejo del simulador
### Calculadora de probabilidad de contagio de COVID-19
##### Variables de entrada
##### Variables de salida
### Modelo SIR - Basado en agentes
##### Variables de entrada
##### Visualización del simulador

## Referencias
* Lelieveld, J., Helleis, F., Borrmann, S., Cheng, Y., Drewnick, F., Haug, G., ... & Pöschl, U. (2020). Model Calculations of Aerosol Transmission and Infection Risk of COVID-19 in Indoor Environments. International Journal of Environmental Research and Public Health, 17(21), 8114.
* Vahdati, A. R. (2019). Agents. jl: agent-based modeling framework in Julia. Journal of Open Source Software, 4(42), 1611.
* Abar, S., Theodoropoulos, G. K., Lemarinier, P., & O’Hare, G. M. (2017). Agent Based Modelling and Simulation tools: A review of the state-of-art software. Computer Science Review, 24, 13-33.
