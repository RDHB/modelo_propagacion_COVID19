### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ ca44a32e-a7f8-11eb-0370-b542b82ce82f
begin
	using Pkg; Pkg.activate("."); Pkg.resolve(); Pkg.instantiate()
	using PlutoUI
	using Random 
	using Plots
	using Agents
	using DrWatson: @dict
	import ..Schedulers
end

# ╔═╡ f92d8460-336b-474e-acdc-18498dd003df
TableOfContents()

# ╔═╡ 4ee63985-cebb-467b-b63f-c83088e94bdd
md"
 # SIMULADOR DE PROPAGACIÓN DE COVID-19 EN AMBIENTES CERRADOS

"

# ╔═╡ 5d621881-0126-43ee-815b-1e4431e136ae
md"
# Teoría
"

# ╔═╡ 3f7c45ca-da9f-48a8-a25e-df5e4937ded6
md"
## Introducción

Existe una creciente evidencia de que la propagación del coronavirus SARS-CoV-2 a través de aerosoles (es decir, pequeñas partículas en el aire y microgotas en el rango de tamaño de hasta 5 µm de diámetro) es una vía de transmisión significativa de COVID-19. Los estudios de casos en todo el mundo indican que el SARS-CoV-2 tiene tasas de supervivencia viables en el aire y permanece en el aire durante un período prolongado de varias horas. 

La transmisión aérea es muy virulenta y representa la ruta dominante en la propagación de COVID-19 . El uso de mascarillas ha sido un aspecto crítico en el resultado de las tendencias de COVID-19. Otras medidas, como el distanciamiento social, parecen haber sido insuficientes, lo que sugiere un papel importante de los aerosoles, ya que se dispersan a distancias relativamente grandes. 

"

# ╔═╡ ac2037db-2802-4907-a266-e6d90c9f6723
md"""
## Calculadora de Probabilidades COVID-19
##### Concentraciones de número de partículas para respirar y hablar:
Las concentraciones de partículas (microgotas) producidas a partir del habla humana pueden oscilar entre 0,1 y 3 cm$$^{-3}$$, dependiendo de la sonoridad. Al volumen más bajo, ni cantar ni hablar son significativamente diferentes de respirar. Se adoptan las concentraciones de número de partículas de 0.06cm$$^{-3}$$ para respirar y 0.6 cm$$^{-3}$$ para hablar.

##### Carga viral altamente infecciosa: 
Los aerosoles o gotitas respiratorias emitidos por personas infectadas tienen la misma carga viral que la que se encuentra en los fluidos dentro de las vías respiratorias que generan estos aerosoles / gotitas. En este caso nos enfocaremos en los sujetos son particularmente infecciosos los cuales tienen una carga viral media de aproximadamente 5*10$$^8$$ copias de ARN/cm$$^3$$. 

##### Vida útil del virus en aerosol: 
Los aerosoles pueden desempeñar un papel en la transmisión del SARS-CoV-2, la vida media del virus SARS-CoV-2 en aerosoles es de aproximadamente 1,1 a 1,2 h dentro de un rango de 0,2 a 3 h. La supervivencia del virus en el aire aumenta con la disminución de la temperatura y la humedad relativa. El rango óptimo de temperatura y humedad relativa para la desactivación del virus se encuentre entre aproximadamente 20-25°C para este caso adoptamos una vida útil media de 1.7 horas.

##### Probabilidad de deposición en los pulmones: 
Los virus en aerosol permanecen en el aire y su inhalación conduce a una captación eficaz en la fosa nasal, faringe y laringe, tráquea y pulmones. Las mediciones y simulaciones de modelos de deposición de partículas dentro del sistema respiratorio indican que para partículas de 1 µm la fracción depositada es relativamente baja, alrededor de 0,2. Esto se aplica a las partículas hidrofóbicas estudiadas en el laboratorio. Dado que las partículas que contienen SARS-CoV-2 son hidrófilas y la humedad relativa en el tracto respiratorio es cercana al 100%, es importante tener en cuenta el crecimiento higroscópico del aerosol, que aumenta la inercia y la sedimentación de las partículas, por lo que existe una probabilidad de deposición de 0,5 resultó ser más realista.

##### No. ARN para 50% probabilidad de infección (D50): 
El número de copias virales que se necesitan para causar una infección puede variar, por ejemplo, dependiendo de las defensas del huésped. Se expresa como D50, siendo la dosis media que provoca una infección en el 50% de los sujetos susceptibles. Para este estudio asumimos que D50 está en el rango de 100 a 1000 y, tomando la media geométrica, llegamos a D50 = 316 copias virales. 

##### Frecuencia respiratoria: 
Una frecuencia respiratoria de 10 L / min es representativo para una persona entre estar en reposo y realizar una actividad ligera.

##### Concentración por respirar:
Las concentraciones de partículas (microgotas) producidas a partir del habla humana pueden oscilar entre 0.1 y 3 cm$$^{-3}$$, dependiendo de la sonoridad . una producción de partículas de aproximadamente 0.1 - 1.1 cm$$^{-3}$$ para el intervalo entre la respiración y la vocalización sostenida.

##### Diámetro del aerosol húmedo:
Normalmente, del 80% al 90% de las partículas de la respiración y el habla tienen un diámetro de alrededor de 1 µm, definido como partículas de aerosol. Tras la emisión del sistema respiratorio humano a una humedad relativa (HR) cercana al 100%, las partículas son inicialmente húmedas y relativamente grandes, pero en el aire ambiente, a una HR reducida, se deshidratan rápidamente y se transforman en aerosoles más o menos secos. El número, tamaño y volumen de las gotitas emitidas según el nivel de vocalización, más la carga viral de SARS-CoV-2, determinan el flujo de virus al medio ambiente. La carga viral en los aerosoles puede ser igual o mayor que en las gotas más grandes. Con base en las distribuciones observadas del tamaño del volumen y el número de las gotitas respiratorias emitidas durante la respiración y el habla y la dependencia del tamaño de la carga viral, en este caso se asume que las gotitas emitidas inicialmente tienen un diámetro promedio efectivo de 5 µm, reduciéndose rápidamente a partículas de aerosol (alrededor de 1 µm) en aire ambiente

##### Episodio Infeccioso:
El período de dos días representa el de mayor infecciosidad del sujeto índice, después del cual se supone que desarrollará síntomas y se quedará en casa o se volverá sustancialmente menos infeccioso.

Parámetro | Valor | Unidades
:------------ | :-------------: | :-------------:
Concentraciones de número de partículas para respirar | 0.06 | cm$$^{-3}$$ 
Concentraciones de número de partículas para hablar | 0.6 | cm$$^{-3}$$
Carga viral altamente infecciosa | 5*10$$^8$$ | Copias de ARN/cm$$^3$$
Vida útil del virus en aerosol | 1.7 | horas
Probabilidad de deposición en los pulmones | 0.5 | -
No. ARN para 50% probabilidad de infección (D50) | 316 | Copias de ARN
Frecuencia respiratoria | 10 | L/min
Concentracion por respirar | 0.1 | cm$$^{-3}$$
Diámetro del aerosol húmedo | 5 | µm
Episodio Infeccioso | 2 | días

### Fórmulas utilizadas en el modelo

Fórmula para calcular el riesgo de infección de una sola copia de ARN viral:

$$P_{ARN}(\%) = 1-10^{\dfrac{\log 10(0.5)}{D50}}*100$$

Fórmula para calcular el riesgo de infección de una persona en la habitación (que una persona en la habitación esté infectada):

$$R_I(\%) = [1-(1-P_{ARN})^{DIP}]*100$$

Fórmula para calcular el riesgo de que una de las personas en la habitación se infecte (que una persona en la habitación se vaya a infectar):

$$R_I(\%) = [1-(1-P_{ARN})^{(DIP*n)}]*100$$

En donde n representa el número de personas en la habitación.

### Eficiencia según el tipo de mascarilla
Muchos estudios han informado que las máscaras faciales reducen sustancialmente el riesgo de infección, lo que se aplica tanto a las máscaras quirúrgicas desechables como a las máscaras de tela reutilizables. El uso de mascarillas funciona de dos maneras, al evitar que los sujetos infectados esparzan gotitas y aerosoles, y al limitar la exposición por inhalación. 

Acción | Mascarilla de tela | Mascarilla quirúrgica
:------------ | :-------------: | :-------------:
Exhalar | 0.5 | 0.65 
Inhalar | 0.2 | 0.3

### Ventilación
Una mala ventilación aumenta el período de tiempo durante el cual los aerosoles se acumulan en la habitación. Los riesgos pueden reducirse significativamente mediante la ventilación regular con aire exterior. La ventilación con aire exterior es útil, ya que reduce el riesgo de infección por aerosol individual.

Tipo de ventilación | Mínimo | Máximo
:------------ | :-------------: | :-------------:
Tasa de ventilación pasiva | 1 | 3 
Tasa de ventilación activa (con aire exterior) | 4 | 9

### Escenario
Evaluamos entornos interiores típicos, como una habitación, un aula, y un bar/restaurante. Los aerosoles de sujetos altamente infecciosos pueden transmitir COVID-19 de manera efectiva en ambientes interiores. El SARS-CoV-2 puede transmitirse a través del aire mediante partículas de aerosol, lo que provoca infecciones por COVID-19 en el ambiente interior.

Escenario | Área del escenario | Altura del Escenario | Unidades
:------------ | :-------------: | :-------------: | :-------------:
Habitación  | 40 | 3 | m$${^3}$$
Aula de clases | 60 | 3 | m$${^3}$$
Bar o restaurante | 100 | 4 | m$${^3}$$
"""

# ╔═╡ 960fe2ac-c284-4987-9f34-9f10bcf55719
md"""
## Modelo Basado en Agentes
"""

# ╔═╡ ab971a7c-dd4d-4aea-88e0-c2d645045df8
md"""
El modelo basado en agente es una forma interesante de realizar simulaciones complejas, consiste en modelar de forma individual diferentes características de fenómenos que permite utilizar este enfoque. 

En este enfoque, los diferentes elementos que componen al sistema pueden ser modelados como como objetos individuales (llamados agentes) los cuales pueden interactuar entre sí acorde a ciertas reglas derivadas del estudio. La interacción entre los elementos es lo que permite encerrar la complejidad del sistema y a su vez permite predecir aspectos relevantes de esta recopilando los datos necesarios.

Un modelo basado en agentes tiene las siguientes características:

* **En espacio de interacción:** Con esta característica se define un espacio geométrico en el cual se realizan las diferentes interacciones entre los elementos del sistema. En este punto se puede pensar en un espacio euclidiano (continuo), en un espacio con puntos de movimiento definidos (como las calles de una ciudad), en un espacio discreto, entre otros. Las posibilidades para el diseño de uno pueden ser variados.

* **Reglas de interacción:** Esta característica consiste en la definición de las diferentes formas en que los elementos del sistema en estudio pueden interactuar. Estas reglas no se limitan a describir comportamientos generales del sistema, sino que pueden definir comportamientos únicos ya que es posible plasmar comportamientos que pertenecen a un agente o elemento específico del sistema.

* **Reglas de paso del modelo:** Un modelo basado en agentes discretiza el tiempo, de este modo en cada paso del tiempo se define qué lo que sucede con el sistema, es decir se hace efectivo la interacción de los elementos y se obtienen el efecto debido a la interacción.

* **Reglas de paso del agente:** Un modelo basado en agentes tiene como componentes a elementos individuale llamados agentes. Tales agentes se mueven en el espacio de interacción definido, por lo que a cada paso del tiempo se define la posición del agente el cuál puede cambiar o no dependiendo de las reglas establecidas.

### Modelo SIR-Basado en Agentes
Ahora enfocamos nuestra atención a modelar el problema de propagación de un virus en una pandemia con un modelo basasado en agentes. En el modelamiento de este problema  cada persona o individuo es considerado como un agente y de forma individual se  les puede asociar diferentes aspectos (obedece reglas de distanciamiento social, probabilidad de contagio por uso de mascarillas o visitas a recurrentes a un lugar público, etc), es la consideración de esa variabilidad lo que vuelve poderoso a este enfoque.

Un modelo simplificador, pero útil de este enfoque, es descrito a continuación:
* **Espacio de interacción:** El espacio de interacción elegido es el euclidiano y continuo. El movimiento de los agentes se restringe a un salón, es decir, tienen límites y no circulan libremente. Un espacio más complejo puede determinarse como uno que imita el movimiento en una ciudad o entre ciudades.

* **Reglas de interacción:** Cada agente dentro del modelo tienen riesgo de contagio si dos o más personas se encuentran dentro de distancias no seguras. Los individuos pueden no obedecer el distanciamiento social, aumenta de este modo la probabilidad de contagio.

* **Reglas de paso del modelo:** En cada paso del modelo se verifica que dos o más agentes se encuentran dentro o en el límite de una distancia no segura. Si una de ellas está infectada acorde a la probabilidad de contagio se procede a analizar si se transmite el virus o no. Si están muy cerca o dentro de un radio dado los agentes cambian la dirección de su movimiento (tal como lo hicieran bolas de de un juego de billar).

* **Reglas de paso del agente:** En cada paso del modelo se modifica la posición del agente, tomando posiciones continuas en una determinada dirección, hasta que esta cambia porque "colisiona" con otro agente o ha llegado a los límites del cuarto que restringe el espacio de su movimiento.


El modelo anterior descrito, es simple para simular la propagación del virus en un ambiente cerrado, cuyas probabilidades de transmisión o riesgo de infectarse son calculadas previamente. Este mismo modelo puede ser modificado para simular la propagación del virus en una ciudad. 
"""

# ╔═╡ dd4cc181-73b4-4c14-9c52-8fa1b3dafaa8
md"
# Simulación
"

# ╔═╡ b78df324-e4bc-40be-a228-c6b8e36a0c93
md"""
## Calculadora de Probabilidades COVID-19
"""

# ╔═╡ b654dee1-3843-4e16-9256-ef67e87ab06f
md"
Uso de la calculadora, cuyos resultados rinden las probabilidades de contagio por una persona que asiste a un evento en ambiente cerrado. Las probabilidades son calculadas acorde al modelo matemático descrito anteriormente.
"

# ╔═╡ 39b16c4f-a083-4e3a-bb43-ae788178c020
md"
### Entradas de la calculadora
"

# ╔═╡ 37e28d2b-891a-4d4e-8bed-b4b28256295d
begin
	vbaja = rand(1:3)
	valta = rand(4:9)
	md""" 
	##### Escenario 
	$(@bind escenario Select(["120" => "Habitación", "180" => "Aula de Clases", "400" => "Bar o Restaurante"])) 
	"""
end

# ╔═╡ 0e62f587-86c3-4ebd-b617-922cd713617b
md"""
##### Tipo de mascarilla:
$(@bind mascarilla Radio(["0.95" => "Mascarilla Quirúrgica","0.7" => "Mascarilla de Tela"]))
"""

# ╔═╡ 682fe24b-e818-48f1-ab02-2c9cda7e4a5d
eficiencia_mascarilla = parse(Float64, mascarilla)
	

# ╔═╡ 1fac5532-a919-478a-b170-a4efe1fd39ad
md"""
##### Ventilación:
"""

# ╔═╡ 7e024c02-81bf-421e-b5bf-61b2e5a85ccd
@bind ventilacion Radio(["$(vbaja)" => "Ventilación Baja","$(valta)" => "Ventilación Alta"])

# ╔═╡ fef57794-7e59-4c2d-a361-93a7df2ceb82
tasa_ventilacion = parse(Int64, ventilacion)

# ╔═╡ eeab906a-5222-4420-97be-62d54c9aa73c
md""" 
##### Cantidad de Personas 
$(@bind cant_persona Slider(5:25;show_value=true))
"""

# ╔═╡ e0e72989-ef74-4b22-afde-13692552598f
md""" 
##### Duración del Evento (Horas) 
$(@bind tiempo Slider(1:12;show_value=true))
"""

# ╔═╡ 22032cc7-d75e-4dcf-a261-e7b515ae52e4
md"
### Salidas de la Calculadora
"

# ╔═╡ 2572384e-9537-44dc-84ef-b2ac15275584
md""" 
##### Probabilidad de infección:
"""

# ╔═╡ ebac4ce8-0fbd-4643-8a1c-775ad18b2be4
md"
##### Contenido de ARN en aerosol:
"

# ╔═╡ 2faccb41-56f6-454a-b4de-4a85a8258c35
md"
##### Emision de aerosoles:
"

# ╔═╡ 561bce1c-4c66-480f-913a-10bd87b4fc09
md"
##### Concentración de aerosoles:
"

# ╔═╡ eafe11b0-a248-4a67-ab5e-20c0a241c9aa
md"

##### ARN concentrado en aerosol:
"

# ╔═╡ f0d4d55e-4912-4e33-bf05-cf54949d7707
md"
##### Dosis de ARN por hora:
"

# ╔═╡ 076c3d2f-e164-49b4-b94e-59f755e7cb6b
md"
##### Dosis de ARN por tiempo de duración del evento:
"

# ╔═╡ 9103c025-40b4-44c0-9ce3-c432d5e605d5
md"
##### Dosis de ARN por un episodio infeccioso:
"

# ╔═╡ a8f73631-32aa-4f05-be78-1fbfc55fb0bf
md"
##### Riesgo de infección de una persona en el escenario:
"

# ╔═╡ a870ec5e-3dd6-47e8-9cf2-cddad23f2427
md"
##### Riesgo que una persona en el escenario se infecte:
"

# ╔═╡ e3afe908-f54d-4c5d-93be-68caa665d4dc
md"""
## Simulador del Modelo Basado en Agentes
"""

# ╔═╡ 1185e24e-2e8e-41d0-9f97-ba65b45ac94c
md"""
##### Cantidad de personas infectadas inicialmente:
$(@bind initial_infected Slider(1:4; show_value=true))
"""

# ╔═╡ 913ef49c-ac00-4f87-9605-bd38b4e71b45
md"""
##### Distancia de interacción mínima segura:
$(@bind interaction_radius Slider(0.5:0.5:1.5; show_value=true))
"""

# ╔═╡ 97d0bcc2-f039-4663-b633-e97725cc933e
begin
	suceptibles = 0
	infected = 0
	@bind i Clock(0.04, max_value = 60*tiempo)
end

# ╔═╡ 274e08c0-be57-4b27-aa3a-3a23a4b4b0fe
md"
**tiempo:** $(i) minutos
"

# ╔═╡ f98d16ee-cb23-487e-859a-c9ee4f3b87f1
md"
# Enviroment Setup
"

# ╔═╡ 61e84224-714c-4ec7-a75a-f854d648d7d0
md"""
### Funciones Calculadora de Probabilidades COVID-19
"""

# ╔═╡ bba9a640-3aa9-468b-a30c-acdc3b4eaabc
begin
	#Variables de estado
	D50 = 316 
	DP = 0.5
	EB = 0.06
	ES = 0.6
	SBR = 0.1
	RR = 10
	RFR = 5*10^8
	MWAD = 5
	IE = 2
	VLA = 1.7
	#Fórmulas para cálculo de parámetro
	volumen_escenario = parse(Int64, escenario)
	probabilidad_infección =1-10^(log10(0.5)/D50)
	RNA_en_aerosol = RFR*pi/6*(MWAD/10000)^3
	emision_aerosoles =(EB*(1-SBR) + ES*SBR) * 1000 * RR * 60
	concentración_aerosol = emision_aerosoles / ( volumen_escenario * 1000)
	RNA_concentrado_aerosol = concentración_aerosol * RNA_en_aerosol
	dosis_RNA = RR * 60 * RNA_concentrado_aerosol * DP
	dosis_hora_dia = dosis_RNA/(tasa_ventilacion + 1/VLA)*(1-eficiencia_mascarilla)*tiempo
	dosis_episodio_infeccioso = dosis_hora_dia * IE
	riesgo_infección_individual = (1-(1-probabilidad_infección)^dosis_episodio_infeccioso) * 100
	dpi = dosis_episodio_infeccioso * cant_persona
	riesgo_infeccion_persona_habitacion =(1-(1-probabilidad_infección)^dpi)*100
end;

# ╔═╡ f09e4198-dded-4167-bb55-aa5686c873bb
with_terminal()do
	println(round(probabilidad_infección, digits = 3))
end

# ╔═╡ 10d29890-50c1-4230-9284-0213f902bfc9
with_terminal()do
	println(round(RNA_en_aerosol, digits = 3))
end

# ╔═╡ 7a9fd62a-935b-4f5c-9965-c66f03509c06
with_terminal()do
	println(round(emision_aerosoles, digits = 3))
end

# ╔═╡ 9583b508-31cc-4068-8a90-b25ad8d7a353
with_terminal()do
	println(round(concentración_aerosol, digits = 3))
end

# ╔═╡ 890eee6b-fff0-4245-9f64-3b795687edc8
with_terminal()do
	println(round(RNA_concentrado_aerosol, digits = 3))
end

# ╔═╡ ca1a63dc-5f92-4437-8290-1719305cd910
with_terminal()do
	println(round(dosis_RNA, digits = 3))
end

# ╔═╡ b2a71924-811d-4944-9d13-545dc6b8104f
with_terminal()do
	println(round(dosis_hora_dia, digits = 3))
end

# ╔═╡ 293071ad-c3b7-4a8e-ba97-ad796e48c151
with_terminal()do
	println(round(dosis_episodio_infeccioso, digits = 3))
end

# ╔═╡ 3e9d1280-134f-4fd5-b5e5-ac1698c9341b
with_terminal()do
	println(round(riesgo_infección_individual, digits = 3))
end

# ╔═╡ 48f63ee3-b9fc-4dbd-8d57-a7b3737fdc1f
with_terminal()do
	println(round(riesgo_infeccion_persona_habitacion, digits = 3))
end

# ╔═╡ cae27515-2915-4221-bd5e-f66bcade4f81
md"
### Funciones Simulador Basado en Agentes
"

# ╔═╡ 0ab16138-13f8-4b13-a1e3-022a797f818b
#Representa a una persona dentro de la habitación, contemplando las propiedades necesarias
mutable struct AgentRoom <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    vel::NTuple{2,Float64}
    mass::Float64
    days_infected::Int  
    status::Symbol  # :S, :I or :R
	obedient::Bool
    β::Float64
end

# ╔═╡ 3e38ccdc-975c-484a-a00f-b984f5eeb182
#Función que sirve para inicializar el modelo y obtenerlo dependiendo de las condiciones dentro de la habitación y de los agentes.
function covid_model_room(
		ancho, #model space 
		largo; #model space
		initial_infected = 1, #property for initialize model
    	interaction_radius = 1.5, #property model
    	dt = 0.5, #property model
    	N = 10, #property model
    	seed = 51234, #property for agent
    	βmin = 0.4, #property for agent
    	βmax = 0.8, #property for agent
		speed = 0.1, #agent
	)
	
	    properties = @dict(interaction_radius, ancho, largo, dt, N)
		space = ContinuousSpace((largo, ancho), 0.1, periodic = true)
    	model = ABM(AgentRoom, space, properties = properties, rng = MersenneTwister(seed))
		
		for i in 1:N
        	pos = (rand(0:largo-1), rand(0:ancho-1))
        	status = i ≤ N - initial_infected ? :gray : :red
        	obedient = rand([true, false])
        	mass = 1.0
        	vel = sincos(2π * rand(model.rng)) .* speed
        	#β = (βmax - βmin) * rand(model.rng) + βmin
        	add_agent!(pos, model, vel, mass, 0, status, obedient, riesgo_infeccion_persona_habitacion/100)
    	end
	
    	return model
end;

# ╔═╡ c4a4802a-f174-4b28-a5ec-e0705bcff49e
begin
	"""
	Regla de transmisión: 
	 * Se escogen dos agentes los cuales uno de ellos puede estar infectado. 
	 * Si los dos están infectados o ninguno la función no realiza ningún cambio en el estatus del agente. 
	 * Si uno de ellos está infectado se realiza un cambio en el status del agente no infectado, luego de analizar la probabilidad de contagio.
	"""
	function covid_model_room_transmit!(agent₁, agent₂, model)
		#Comprobación para saber si hay un infectado o no
    	count(agent.status == :red for agent in (agent₁, agent₂)) ≠ 1 && return
    	infected, not_infected = agent₁ == :red ? (agent₁, agent₂) : (agent₂, agent₁)
		
		#Comprobación para saber si acorde a las probabilidades la enfermedad se transmite o no
		β = not_infected.obedient && infected.obedient ? not_infected.β + 0.1 : not_infected.β
    	rand(model.rng) > β && return
    	not_infected.status = :red
	end	
	
	"""
	Regla para el manejo del modelo en cada paso de los agentes:
	 * Se define si es posible la trasmisión de la enfermedad dado los pasos que dan los agentes.
	 * Se define un cambio en la dirección de los agentes si se encuentran dentro de un rango dado. Los agentes son modelados como bolas de billar.
	"""
	function covid_model_room_step!(model)
   		r_model= model.interaction_radius
    	for (agent₁, agent₂) ∈ interacting_pairs(model, r_model, :all)
        	covid_model_room_transmit!(agent₁, agent₂, model)
        	elastic_collision!(agent₁, agent₂, :mass)
    	end
		
	end
	
	function move_agent_room!(agent, model)
		new_pos = agent.pos .+ agent.vel .* model.dt
		
		if new_pos[1] ∈ 0 : model.largo &&  new_pos[2] ∈ 0 : model.ancho
			
		elseif new_pos[1] ≤ 0 || new_pos[1] ≥ model.largo
			agent.vel = (-agent.vel[1], agent.vel[2])
		elseif new_pos[2] ≤ 0 || new_pos[2] ≥ model.ancho
			agent.vel = (agent.vel[1], -agent.vel[2])	
		end
		
		model.space.update_vel!(agent, model)
		pos = agent.pos .+ agent.vel .* model.dt
		move_agent!(agent, pos, model)
		return agent.pos
		
	end
	
	function covid_model_room_agent_step!(agent, model)
		move_agent_room!(agent, model)
	end	
end;

# ╔═╡ 2a836fc3-49f3-417b-8fb1-f37fbdcd1e4a
begin
	ancho = rand(5:0.5:14)
	largo = floor(parse(Float64, escenario)/ancho)
	time =  tiempo * 60
	
	model₁ =  covid_model_room(
		ancho, 
		largo, 
		initial_infected  = initial_infected,
		interaction_radius = interaction_radius,
		N = cant_persona,
	)
	
	
	adata, _ = run!(model₁, covid_model_room_agent_step!, covid_model_room_step!, 60*tiempo; adata = [:pos, :status])
	
	
end;

# ╔═╡ 42d0e5d7-d934-4e50-acdb-12f75749efa2
begin
	data = adata[adata.step .== i, [:pos, :status]]
		data_gray = data[data.status .== :gray, :pos]
		data_red = data[data.status .== :red, :pos]
		plt = plot(title = "INTERACCIÓN EN EL ESCENARIO", legend = :outertopleft, xticks = (0:2:largo, ["$(i)" for i ∈ 0:2:largo]), xlims = (0, largo), xtickfontsize = 5, yticks = (0:2:ancho, ["$(i)" for i ∈ 0:2:ancho]), ylims = (0, ancho), ytickfontsize = 5, xlabel = "Largo (m)", ylabel = "Ancho (m)")
		scatter!(plt, data_gray, markercolor = :gray, markershape = :circ, label = "Suceptibles $(length(data_gray))")
		scatter!(plt, data_red, markercolor = :red, markershape = :hex, label = "Infectados $(length(data_red))")
end

# ╔═╡ Cell order:
# ╟─f92d8460-336b-474e-acdc-18498dd003df
# ╟─4ee63985-cebb-467b-b63f-c83088e94bdd
# ╟─5d621881-0126-43ee-815b-1e4431e136ae
# ╟─3f7c45ca-da9f-48a8-a25e-df5e4937ded6
# ╟─ac2037db-2802-4907-a266-e6d90c9f6723
# ╟─960fe2ac-c284-4987-9f34-9f10bcf55719
# ╟─ab971a7c-dd4d-4aea-88e0-c2d645045df8
# ╟─dd4cc181-73b4-4c14-9c52-8fa1b3dafaa8
# ╟─b78df324-e4bc-40be-a228-c6b8e36a0c93
# ╟─b654dee1-3843-4e16-9256-ef67e87ab06f
# ╟─39b16c4f-a083-4e3a-bb43-ae788178c020
# ╟─37e28d2b-891a-4d4e-8bed-b4b28256295d
# ╟─0e62f587-86c3-4ebd-b617-922cd713617b
# ╟─682fe24b-e818-48f1-ab02-2c9cda7e4a5d
# ╟─1fac5532-a919-478a-b170-a4efe1fd39ad
# ╟─7e024c02-81bf-421e-b5bf-61b2e5a85ccd
# ╟─fef57794-7e59-4c2d-a361-93a7df2ceb82
# ╟─eeab906a-5222-4420-97be-62d54c9aa73c
# ╟─e0e72989-ef74-4b22-afde-13692552598f
# ╟─22032cc7-d75e-4dcf-a261-e7b515ae52e4
# ╟─2572384e-9537-44dc-84ef-b2ac15275584
# ╟─f09e4198-dded-4167-bb55-aa5686c873bb
# ╟─ebac4ce8-0fbd-4643-8a1c-775ad18b2be4
# ╟─10d29890-50c1-4230-9284-0213f902bfc9
# ╟─2faccb41-56f6-454a-b4de-4a85a8258c35
# ╟─7a9fd62a-935b-4f5c-9965-c66f03509c06
# ╟─561bce1c-4c66-480f-913a-10bd87b4fc09
# ╟─9583b508-31cc-4068-8a90-b25ad8d7a353
# ╟─eafe11b0-a248-4a67-ab5e-20c0a241c9aa
# ╟─890eee6b-fff0-4245-9f64-3b795687edc8
# ╟─f0d4d55e-4912-4e33-bf05-cf54949d7707
# ╟─ca1a63dc-5f92-4437-8290-1719305cd910
# ╟─076c3d2f-e164-49b4-b94e-59f755e7cb6b
# ╟─b2a71924-811d-4944-9d13-545dc6b8104f
# ╟─9103c025-40b4-44c0-9ce3-c432d5e605d5
# ╟─293071ad-c3b7-4a8e-ba97-ad796e48c151
# ╟─a8f73631-32aa-4f05-be78-1fbfc55fb0bf
# ╟─3e9d1280-134f-4fd5-b5e5-ac1698c9341b
# ╟─a870ec5e-3dd6-47e8-9cf2-cddad23f2427
# ╟─48f63ee3-b9fc-4dbd-8d57-a7b3737fdc1f
# ╟─e3afe908-f54d-4c5d-93be-68caa665d4dc
# ╟─1185e24e-2e8e-41d0-9f97-ba65b45ac94c
# ╟─913ef49c-ac00-4f87-9605-bd38b4e71b45
# ╟─97d0bcc2-f039-4663-b633-e97725cc933e
# ╟─274e08c0-be57-4b27-aa3a-3a23a4b4b0fe
# ╟─2a836fc3-49f3-417b-8fb1-f37fbdcd1e4a
# ╟─42d0e5d7-d934-4e50-acdb-12f75749efa2
# ╟─f98d16ee-cb23-487e-859a-c9ee4f3b87f1
# ╠═ca44a32e-a7f8-11eb-0370-b542b82ce82f
# ╟─61e84224-714c-4ec7-a75a-f854d648d7d0
# ╠═bba9a640-3aa9-468b-a30c-acdc3b4eaabc
# ╟─cae27515-2915-4221-bd5e-f66bcade4f81
# ╠═0ab16138-13f8-4b13-a1e3-022a797f818b
# ╠═3e38ccdc-975c-484a-a00f-b984f5eeb182
# ╠═c4a4802a-f174-4b28-a5ec-e0705bcff49e
