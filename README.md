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
* using Pkg
* Pkg.activate(".")
* Pkg.resolve()
* Pkg.instantiate()


En orden las líneas anteriores realizan las siguientes acciones:
* Manejador de paquetes de Julia.
* Esta línea de comando activa un ambiente virtual en la carpeta donde se encuentra el archivo mencionado, en este caso la carpeta que constituye este repositorio, que además contiene los archivos "Manifest.toml" y "Project.toml".
* Actualiza el grafo de dependencias declarado en los archivos adicionales mencionados.
* Instala las dependencias necesarias para correr el proyecto.


Para que los pasos anteriores realicen la función deseada, se debe asegurar que el REPL de Julia corra desde el directorio de trabajo donde se encuentran los archivos "Manifest.toml" y "Project.toml". Con las dependencias instaladas y el entorno virtual activado, desde el REPL se abre el notebook de Pluto con los comandos: 
* using Pluto; Pluto.run()

## Manejo del simulador
### Calculadora de probabilidad de contagio de COVID-19
#### Variables de entrada
 A continuación, se describen las variables que constituyen la entrada para la Calculadora de Probabilidad de contagio de COVID-19.

Variable  | Descripción
--------- | ------------
Escenario | Se evaluan interiores típicos: una habitación, un aula, y un bar/restaurante. Tomando en consderación que la habitación tendrá un área de 40 m^2 y 3 m de altura, por lo cual su volumen será de 40x3 m^3. En el caso de un aula de clases su área sera 60 m^2 y su altura de 3 m, y el volumen sera de 60X3 m^3 y finalmente el área del bar/restaurante es de 100 m^2, con una altura de 4 m, teniendo así 100x4 m^3.
Tipo de Mascarilla | Se consideran 2 tipos de mascarilla de los cuales obtenemos su eficiencia para realizar calculos posteriores. El primer tipo de mascarilla es la mascarilla quirúrgica la cual tiene una eficiencia de 0.65 para el momento en que la persona exhala al respirar o hablar y de 0.3  para el momento en que la persona inhala. Sumando estos dos valores obtenemos un resultado total de  eficiencia de 0.95. El segundo tipo de mascarilla es la de tela la cual tiene una eficiencia de 0.5  para el momento en que la persona exhala al respirar o hablar y de 0.2 para el momento en que la  persona inhala. Sumando estos dos valores obtenemos un resultado total de eficiencia de 0.7.
Ventilación | Se consideran 2 tipos de ventilación de los cuales obtenemos el valor para la tasa de ventilación del escenario. Para cada uno de los tipo se estableció un rango de valores, al escoger  la opción deseada, el valor de la tasa de ventilación se obtendrá de manera aleatoria respetando los valores mínimos y máximos de dichos rangos. El primer tipo es la ventilación baja con un rango de [1,3] para el valor de la tasa. El segundo tipo es la ventilación alta con un rango de [4,9] para el valor de la tasa.
Cantidad de personas | Para la cantidad de personas que se encuentran en el escenario se consideró un valor mínimo de 5 personas y máximo de 25 personas.
Duración del evento | Para esta variable se consideró un mínimo de 1 hora y un máximo de 12 horas en las cuales las personas estarán reunidas en el escenario.

### Variables de estado
#### D50
Determina la cantidad de copias virales de ARN. 
#### Carga viralmente infecciosa 
Determina la cantidad de copias de ARN que emite un sujeto infeccioso. 
#### Diámetro de aerosol húmedo. 
Diámetro de la partícula de aerosol que se encuentran en aire ambiente y son emitidas por personas. 
#### Concentración por respirar
Determina la concentración de partículas que la persona respirará. 
#### Concentración de N° de partículas para hablar
Determina la concentración de partículas producidas a partir del habla. 
#### Concentración de N° de partículas para respirar
Determina la concentración de partículas producidas a partir de la respiración.
#### Frecuencia respiratoria 
Determina el ritmo respiratorio de una persona cuando está en reposo o realiza una actividad ligera.
#### Probabilidad de deposición en los pulmones 
Determina la probabilidad de que el virus que permanece en el aerosol se deposite en los pulmones. 
#### Vida útil del virus en aerosol 
Determina el tiempo de vida del virus en el aerosol.
#### Episodio infeccioso 
Determina los dias de mayor infecciosidad del sujeto. 

### Variables de salida
#### Probabilidad de Infección 
Determina el riesgo de infección de una sola copia de ARN viral.
#### Contenido de ARN en aerosol
Determina la  cantidad de  ARN viral que existe en el aerosol. 
#### Emisión de aerosoles
Determina la cantidad de emisión de aerosoles de una persona. 
#### Concentración de aerosoles
Determina cuanta cantidad de emisión de aerosoles de una persona se encuentra en un escenario específico. 
#### ARN concentrado en aerosol
Determina cantidad de ARN viral en la concentración de aerosoles. 
#### Dosis de ARN por hora
Determina la cantidad de ARN viral en la concentración de aerosol por una hora.
#### Dosis de ARN por tiempo de duración del evento
Determina la cantidad de ARN viral en la concentración de aerosol por un tiempo específico(tomando en cuenta la tasa de ventilación y la eficiencia de la mascarilla).
#### Dosis de ARN por un episodio infeccioso
Determina la dosis de ARN por tiempo de duración del evento, durante un episodio infeccioso.
#### Riesgo de infección de una persona en el escenario 
Determina el porcentaje del riesgo de que una persona en la habitación esté infectada.
#### Riesgo que una persona en el escenario se infecte
Determina el porcentaje de riesgo de que una persona en la habitación se infecte. 

### Modelo SIR - Basado en agentes
Esta parte del proyecto constituye la parte visual de la simulación donde se puede observar cómo se propaga el virus que causa el COVID-19 entre las personas que se encuentran en un ambiente cerrado. A continuación, se describen las variables que constituyen la entrada para la simulación visual y cómo se relaciona con la calculadora de probabilidad, cualquier cambio en estas últimas variables constituye un cambio automático en la simulación reconstruyéndose visualmente la simulación.
#### Variables de entrada
##### Cantidad de personas en el cuarto
Determina la cantidad de agentes presentes en la simulación. Esta variable está definida con la calculadora de probabilidades. 
##### Duración del evento
Determina la cantidad de pasos que deben ser considerados en la simulación. Esta variable está definida con la calculadora de probabilidades y se declara en horas. Para la simulación cada paso dado constituye un minuto, por lo que se transforma esta variable multiplicando por el factor de 60.
##### Riesgo que una persona en el escenario se infecte
Determina la probabilidad que un agente dentro de la simulación salga infectado luego de una interacción dentro del ambiente cerrado. Esta variable está definida con la calculadora de probabilidades.
#####  Cantidad de personas infectadas inicialmente
Determina la cantidad de personas que se encuentran infectadas desde el inicio de la simulación. Para efecto del simulador esta variable siempre debe ser distinto de cero y menor que la cantidad de personas total en el ambiente cerrado, esta variable está definida para tener un valor dentro del rango de 1 a 4. 
##### Distancia de interacción mínima segura
Determina cuál es la distancia mínima permitida que asegura una interacción entre los agentes con probabilidad de transmisión. Esta variable puede tomar los valores 0.5, 1.0, 1.5 y 2.0 (en metros).

#### Visualización del simulador
* La interacción entre los agentes dentro del ambiente cerrado se visualiza en un gráfico, los agentes infectados se representan con un hexágono de color rojo y las personas suceptibles con un círculo de color gris. 
* El espacio de interacción queda definido en un área determinada por el tipo de escenario elegido en calculadora de probabilidades. 
* La cantidad de personas infectadas y suceptibles se visualiza en la leyenda del gráfico.
* El simulador presenta un botón para dar inicio al simulador y con el mismo botón el simulador puede detenerse. Justo debajo del botón la cantidad de tiempo transcurrido puede observarse en minutos.

## Referencias
* Lelieveld, J., Helleis, F., Borrmann, S., Cheng, Y., Drewnick, F., Haug, G., ... & Pöschl, U. (2020). Model Calculations of Aerosol Transmission and Infection Risk of COVID-19 in Indoor Environments. International Journal of Environmental Research and Public Health, 17(21), 8114.
* Vahdati, A. R. (2019). Agents. jl: agent-based modeling framework in Julia. Journal of Open Source Software, 4(42), 1611.
* Abar, S., Theodoropoulos, G. K., Lemarinier, P., & O’Hare, G. M. (2017). Agent Based Modelling and Simulation tools: A review of the state-of-art software. Computer Science Review, 24, 13-33.
