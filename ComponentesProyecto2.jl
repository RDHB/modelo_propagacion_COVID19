### A Pluto.jl notebook ###
# v0.14.0

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

# ╔═╡ 3db63228-b80b-4b67-86ff-f11c0701589f
begin 
	using Pkg
	Pkg.activate(".")
	Pkg.instantiate()
	#using Plots
	#using PlutoUI
end

# ╔═╡ 266e755f-df14-4912-acf0-8c2d5fdd5ed4
using InteractiveUtils

# ╔═╡ a8fb3bb1-458b-4ed8-b14e-becee42e87d6
begin
	using Plots
	using PlutoUI
end

# ╔═╡ 3c363169-e14f-435c-8120-644253c2a814
md" # Simulador de propagación de Covid-19 en ambientes cerrados

### Introducción

Existe una creciente evidencia de que la propagación del coronavirus SARS-CoV-2 a través de aerosoles (es decir, pequeñas partículas en el aire y microgotas en el rango de tamaño de hasta 5 µm de diámetro) es una vía de transmisión significativa de COVID-19. Los estudios de casos en todo el mundo indican que el SARS-CoV-2 tiene tasas de supervivencia viables en el aire y permanece en el aire durante un período prolongado de varias horas. 

La transmisión aérea es muy virulenta y representa la ruta dominante en la propagación de COVID-19 . El uso de mascarillas ha sido un aspecto crítico en el resultado de las tendencias de COVID-19. Otras medidas, como el distanciamiento social, parecen haber sido insuficientes, lo que sugiere un papel importante de los aerosoles, ya que se dispersan a distancias relativamente grandes. 

### Parámetros del modelo aplicados para calcular el riesgo de infección

Concentraciones de número de partículas para respirar y hablar:
Las concentraciones de partículas (microgotas) producidas a partir del habla humana pueden oscilar entre 0,1 y 3 cm$$^{-3}$$, dependiendo de la sonoridad. Al volumen más bajo, ni cantar ni hablar son significativamente diferentes de respirar. Se adoptan las concentraciones de número de partículas de 0.06cm$$^{-3}$$ para respirar y 0.6 cm$$^{-3}$$ para hablar.

Carga viral altamente infecciosa: 
Los aerosoles o gotitas respiratorias emitidos por personas infectadas tienen la misma carga viral que la que se encuentra en los fluidos dentro de las vías respiratorias que generan estos aerosoles / gotitas. En este caso nos enfocaremos en los sujetos son particularmente infecciosos los cuales tienen una carga viral media de aproximadamente 5*10$$^8$$ copias de ARN/cm$$^3$$. 

Vida útil del virus en aerosol: 
Los aerosoles pueden desempeñar un papel en la transmisión del SARS-CoV-2, la vida media del virus SARS-CoV-2 en aerosoles es de aproximadamente 1,1 a 1,2 h dentro de un rango de 0,2 a 3 h. La supervivencia del virus en el aire aumenta con la disminución de la temperatura y la humedad relativa. El rango óptimo de temperatura y humedad relativa para la desactivación del virus se encuentre entre aproximadamente 20-25°C para este caso adoptamos una vida útil media de 1.7 horas.

Probabilidad de deposición en los pulmones: 
Los virus en aerosol permanecen en el aire y su inhalación conduce a una captación eficaz en la fosa nasal, faringe y laringe, tráquea y pulmones. Las mediciones y simulaciones de modelos de deposición de partículas dentro del sistema respiratorio indican que para partículas de 1 µm la fracción depositada es relativamente baja, alrededor de 0,2. Esto se aplica a las partículas hidrofóbicas estudiadas en el laboratorio. Dado que las partículas que contienen SARS-CoV-2 son hidrófilas y la humedad relativa en el tracto respiratorio es cercana al 100%, es importante tener en cuenta el crecimiento higroscópico del aerosol, que aumenta la inercia y la sedimentación de las partículas, por lo que existe una probabilidad de deposición de 0,5 resultó ser más realista.

No. ARN para 50% probabilidad de infección (D50): 
El número de copias virales que se necesitan para causar una infección puede variar, por ejemplo, dependiendo de las defensas del huésped. Se expresa como D50, siendo la dosis media que provoca una infección en el 50% de los sujetos susceptibles. Para este estudio asumimos que D50 está en el rango de 100 a 1000 y, tomando la media geométrica, llegamos a D50 = 316 copias virales. 

Frecuencia respiratoria: 
Una frecuencia respiratoria de 10 L / min es representativo para una persona entre estar en reposo y realizar una actividad ligera.

Concentración por respirar:
Las concentraciones de partículas (microgotas) producidas a partir del habla humana pueden oscilar entre 0.1 y 3 cm$$^{-3}$$, dependiendo de la sonoridad . una producción de partículas de aproximadamente 0.1 - 1.1 cm$$^{-3}$$ para el intervalo entre la respiración y la vocalización sostenida.

Diámetro del aerosol húmedo:
Normalmente, del 80% al 90% de las partículas de la respiración y el habla tienen un diámetro de alrededor de 1 µm, definido como partículas de aerosol. Tras la emisión del sistema respiratorio humano a una humedad relativa (HR) cercana al 100%, las partículas son inicialmente húmedas y relativamente grandes, pero en el aire ambiente, a una HR reducida, se deshidratan rápidamente y se transforman en aerosoles más o menos secos. El número, tamaño y volumen de las gotitas emitidas según el nivel de vocalización, más la carga viral de SARS-CoV-2, determinan el flujo de virus al medio ambiente. La carga viral en los aerosoles puede ser igual o mayor que en las gotas más grandes. Con base en las distribuciones observadas del tamaño del volumen y el número de las gotitas respiratorias emitidas durante la respiración y el habla y la dependencia del tamaño de la carga viral, en este caso se asume que las gotitas emitidas inicialmente tienen un diámetro promedio efectivo de 5 µm, reduciéndose rápidamente a partículas de aerosol (alrededor de 1 µm) en aire ambiente

Episodio Infeccioso:
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

"

# ╔═╡ 22240204-2669-45d5-a55f-7780f853b8da
begin
	vbaja = rand(1:3)
	println()
end

# ╔═╡ 556e54fd-050b-4328-8d9d-93778297a60d
begin
	valta = rand(4:9)
	println()
end

# ╔═╡ af822d1a-f291-4880-b450-15d5597e7135

md""" Escenario $(@bind escenario Select(["120" => "Habitación", "180" => "Aula de Clases", "400" => "Bar o Restaurante"])) """
	

# ╔═╡ 5dbbe4e8-c4e4-49cf-a2c2-dd49f0919be7
md" Tipo de Mascarilla:"

# ╔═╡ f9051ade-9d2f-43a8-9aa2-f770f450a057
@bind mascarilla Radio(["0.95" => "Mascarilla Quirúrgica","0.7" => "Mascarilla de 
	Tela"])

# ╔═╡ 9cab6957-b515-4310-8403-0d0904fff372
begin
	eficiencia_mascarilla = parse(Float64, mascarilla)
	md" Eficiencia de la mascarilla = $eficiencia_mascarilla"
end

# ╔═╡ 9d986a53-a87c-492c-9cd1-dbb7e35dda7a
md" Ventilación:"

# ╔═╡ a251ca83-0a18-4f64-ab0e-8174d2269231
  @bind ventilacion Radio(["$(vbaja)" => "Ventilación Baja","$(valta)" => "Ventilación Alta"]) 

# ╔═╡ 1a31b5ed-09f4-4351-81b9-1b95e79da615
begin
	tasa_ventilacion = parse(Int64, ventilacion)
	md" Tasa de ventilacion = $tasa_ventilacion"
end

# ╔═╡ b67df0f7-9662-4865-a1dc-7a4bf6d269c4
md""" 
Cantidad de Personas $(@bind cant_persona Slider(5:25;show_value=true))
"""

# ╔═╡ b1bc9d5e-9cc0-4b85-bb17-ee21aa1eeb55
md""" 
Duración del Evento (Horas) $(@bind tiempo Slider(1:12;show_value=true))
"""

# ╔═╡ a995105f-d130-4c44-bc7e-048372a7d067
begin
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
	println()
end 

# ╔═╡ fa961ee3-09f2-4a15-b852-96e6e298241c
md""" Probabilidad de Infección:
$(probabilidad_infección)

Contenido de ARN en aerosol:
$(RNA_en_aerosol)

Emision de aerosoles:
$(emision_aerosoles)

Concentracion de aerosoles:
$(concentración_aerosol)

ARN concentrado en aerosol:
$(RNA_concentrado_aerosol)

Dosis de ARN por hora:
$(dosis_RNA)

Dosis de ARN por tiempo de duración del evento:
$(dosis_hora_dia)

Dosis de ARN por un episodio infeccioso:
$(dosis_episodio_infeccioso)

Riesgo de infección de una persona en el escenario :
$(riesgo_infección_individual)

Riesgo que una persona en el escenario se infecte:
$(riesgo_infeccion_persona_habitacion)

"""

# ╔═╡ 5f1c062f-44f4-4bbe-9388-a307eb120cb6
if escenario == "120" 
		area_escenario = parse(Int64, escenario)/3
elseif escenario == "180" 
		area_escenario = parse(Int64, escenario)/3
elseif escenario == "400" 
		area_escenario = parse(Int64, escenario)/4
	    println()
end

# ╔═╡ Cell order:
# ╟─266e755f-df14-4912-acf0-8c2d5fdd5ed4
# ╟─3db63228-b80b-4b67-86ff-f11c0701589f
# ╟─a8fb3bb1-458b-4ed8-b14e-becee42e87d6
# ╟─3c363169-e14f-435c-8120-644253c2a814
# ╟─22240204-2669-45d5-a55f-7780f853b8da
# ╟─556e54fd-050b-4328-8d9d-93778297a60d
# ╟─af822d1a-f291-4880-b450-15d5597e7135
# ╟─5dbbe4e8-c4e4-49cf-a2c2-dd49f0919be7
# ╟─f9051ade-9d2f-43a8-9aa2-f770f450a057
# ╟─9cab6957-b515-4310-8403-0d0904fff372
# ╟─9d986a53-a87c-492c-9cd1-dbb7e35dda7a
# ╟─a251ca83-0a18-4f64-ab0e-8174d2269231
# ╟─1a31b5ed-09f4-4351-81b9-1b95e79da615
# ╟─b67df0f7-9662-4865-a1dc-7a4bf6d269c4
# ╟─b1bc9d5e-9cc0-4b85-bb17-ee21aa1eeb55
# ╟─a995105f-d130-4c44-bc7e-048372a7d067
# ╟─fa961ee3-09f2-4a15-b852-96e6e298241c
# ╟─5f1c062f-44f4-4bbe-9388-a307eb120cb6
