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

# ╔═╡ 2287b761-7a98-4399-a4fb-22660508c3ef
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
	println()
end

# ╔═╡ 22240204-2669-45d5-a55f-7780f853b8da
vbaja = rand(1:3)

# ╔═╡ 556e54fd-050b-4328-8d9d-93778297a60d
valta = rand(4:9)

# ╔═╡ 3c363169-e14f-435c-8120-644253c2a814
md""" ### Propagación de Covid-19 en ambientes cerrados."""

# ╔═╡ af822d1a-f291-4880-b450-15d5597e7135
md""" Escenario $(@bind escenario Select(["120" => "Habitación", "180" => "Aula de Clases", "4000" => "Bar o Restaurante"])) """

# ╔═╡ 5974847f-9cf8-460f-aad4-4e51c46fd68d
volumen_escenario = parse(Int64, escenario)

# ╔═╡ 5dbbe4e8-c4e4-49cf-a2c2-dd49f0919be7
md" Tipo de Mascarilla:"

# ╔═╡ f9051ade-9d2f-43a8-9aa2-f770f450a057
@bind mascarilla Radio(["1.2" => "Mascarilla Quirúrgica","0.7" => "Mascarilla de 
	Tela"])

# ╔═╡ 9cab6957-b515-4310-8403-0d0904fff372
eficiencia_mascarilla = parse(Float64, mascarilla)

# ╔═╡ 9d986a53-a87c-492c-9cd1-dbb7e35dda7a
md" Ventilación:"

# ╔═╡ a251ca83-0a18-4f64-ab0e-8174d2269231
  @bind ventilacion Radio(["$(vbaja)" => "Ventilación Baja","$(valta)" => "Ventilación Alta"]) 

# ╔═╡ 1a31b5ed-09f4-4351-81b9-1b95e79da615
tasa_ventilacion = parse(Int64, ventilacion)

# ╔═╡ b67df0f7-9662-4865-a1dc-7a4bf6d269c4
md""" 
Cantidad de Personas $(@bind cant_persona Slider(5:25;show_value=true))
"""

# ╔═╡ b1bc9d5e-9cc0-4b85-bb17-ee21aa1eeb55
md""" 
Duración del Evento (Horas) $(@bind tiempo Slider(1:12;show_value=true))
"""

# ╔═╡ 5955f9ad-1bfc-4e9f-9ff3-3f67e17275c0
begin
	probabilidad_infección = 1-10^(log10(0.5)/D50)
	println()
end

# ╔═╡ fa961ee3-09f2-4a15-b852-96e6e298241c
md""" Probabilidad de Infección:
$(probabilidad_infección)
"""

# ╔═╡ 417e35f8-b837-40c8-9996-d436c0d0cb69
begin
	RNA_en_aerosol = RFR*pi/6*(MWAD/10000)^3
	println()
end

# ╔═╡ 29bbc0fa-723a-46b2-9151-3092a8f6fc5a
md""" Contenido de RNA en aerosol:
$(RNA_en_aerosol)
"""

# ╔═╡ e6b6bc28-9258-47f5-9808-e3522c03589b
begin
	emision_aerosoles =(EB*(1-SBR) + ES*SBR) * 1000 * RR * 60
	println()
end

# ╔═╡ 1033492e-3c19-49d1-b05a-66971a6251f9
md""" Emision de aerosoles:
$(emision_aerosoles)
"""

# ╔═╡ 83e0307d-3eaa-49ff-b0a7-3e1027dcb2db
begin
	concentración_aerosol = emision_aerosoles / ( volumen_escenario * 1000)
	println()
end

# ╔═╡ e14c41c5-95e2-40d4-98be-ebc71a29ee34
md""" concentracion de aerosoles:
$(concentración_aerosol)
"""

# ╔═╡ 69748997-2fd7-4934-b24a-0619e4c09297
begin
	RNA_concentrado_aerosol = concentración_aerosol * RNA_en_aerosol
	println()
	RNA_concentrado_aerosol
end

# ╔═╡ fd98d446-76d4-4ce1-b2f0-b5ab4151c01f
begin
	dosis_RNA = RR * 60 * RNA_concentrado_aerosol * DP
	dosis_RNA
end

# ╔═╡ 875d1fd6-2178-4a04-9bed-4f53fabcb910
dosis_6hr_dia = dosis_RNA/(tasa_ventilacion + 1/VLA)*(1-eficiencia_mascarilla)*tiempo


# ╔═╡ 67419e0f-c294-4f3e-838e-292b17ccb49f
dosis_episodio_infeccioso = dosis_6hr_dia * IE

# ╔═╡ f0d03a1c-4b89-4332-9b04-667865acbffc
riesgo_infección_individual = (1-(1-probabilidad_infección)^dosis_episodio_infeccioso) * 100

# ╔═╡ 774c0b68-3b0c-443d-bf35-f7ca7aa51da0
riesgo_infeccion_persona_habitacion =(1-(1-probabilidad_infección)^dosis_episodio_infeccioso^cant_persona) * 100

# ╔═╡ 3dade44c-a4d3-41eb-bb9a-d2c3b9be1585
begin
	x = 1:10; y = rand(10, 2); # These are the plotting data
	gr() # We will continue onward using the GR backend
    plot(x, y, seriestype = :scatter, title = "Propagación de COVID-19")
end

# ╔═╡ Cell order:
# ╟─266e755f-df14-4912-acf0-8c2d5fdd5ed4
# ╟─3db63228-b80b-4b67-86ff-f11c0701589f
# ╟─a8fb3bb1-458b-4ed8-b14e-becee42e87d6
# ╟─2287b761-7a98-4399-a4fb-22660508c3ef
# ╟─22240204-2669-45d5-a55f-7780f853b8da
# ╟─556e54fd-050b-4328-8d9d-93778297a60d
# ╟─3c363169-e14f-435c-8120-644253c2a814
# ╟─af822d1a-f291-4880-b450-15d5597e7135
# ╟─5974847f-9cf8-460f-aad4-4e51c46fd68d
# ╟─5dbbe4e8-c4e4-49cf-a2c2-dd49f0919be7
# ╟─f9051ade-9d2f-43a8-9aa2-f770f450a057
# ╟─9cab6957-b515-4310-8403-0d0904fff372
# ╟─9d986a53-a87c-492c-9cd1-dbb7e35dda7a
# ╟─a251ca83-0a18-4f64-ab0e-8174d2269231
# ╟─1a31b5ed-09f4-4351-81b9-1b95e79da615
# ╟─b67df0f7-9662-4865-a1dc-7a4bf6d269c4
# ╟─b1bc9d5e-9cc0-4b85-bb17-ee21aa1eeb55
# ╟─5955f9ad-1bfc-4e9f-9ff3-3f67e17275c0
# ╟─fa961ee3-09f2-4a15-b852-96e6e298241c
# ╟─417e35f8-b837-40c8-9996-d436c0d0cb69
# ╟─29bbc0fa-723a-46b2-9151-3092a8f6fc5a
# ╟─e6b6bc28-9258-47f5-9808-e3522c03589b
# ╟─1033492e-3c19-49d1-b05a-66971a6251f9
# ╟─83e0307d-3eaa-49ff-b0a7-3e1027dcb2db
# ╟─e14c41c5-95e2-40d4-98be-ebc71a29ee34
# ╟─69748997-2fd7-4934-b24a-0619e4c09297
# ╟─fd98d446-76d4-4ce1-b2f0-b5ab4151c01f
# ╠═875d1fd6-2178-4a04-9bed-4f53fabcb910
# ╟─67419e0f-c294-4f3e-838e-292b17ccb49f
# ╠═f0d03a1c-4b89-4332-9b04-667865acbffc
# ╠═774c0b68-3b0c-443d-bf35-f7ca7aa51da0
# ╠═3dade44c-a4d3-41eb-bb9a-d2c3b9be1585
