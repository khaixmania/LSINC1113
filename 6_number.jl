### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 06679a09-47d7-4024-8232-4954c08747a0
using PlutoUI, Primes

# ╔═╡ 1b1d5c9b-5fc7-480e-9649-e9c44a49c38d
include("utils.jl")

# ╔═╡ 736307ec-a2a4-11ef-0f85-ad1a0093e06a
md"# La théorie des nombres"

# ╔═╡ cbabee34-2ca2-4ad4-93ba-2ec3c941da5e
md"""
Si tous les mois avaient 30 jours, est-ce qu'il y a des jours de la semaine qui ne seront jamais le premier du mois ?

Reformulation: pour tout nombre ``0 \le j < 7``, existe-t-il ``x`` et ``y`` tels que ``30x = j + 7y``. Notation modulo : ``30x \equiv j \pmod{7}``.

Si tous les ans avaient 365 jours, est-ce qu'il y a des jours de la semaine qui ne seront jamais le jours de Noël ? Est si tous les ans avaient 366 jours ? Et s'ils avaient 364 jours ?

Reformulation: pour tout nombre ``0 \le j < 7``, existe-t-il ``x`` et ``y`` tels que ``365x = j + 7y``. Notation modulo : ``365x \equiv j \pmod{7}``.
"""

# ╔═╡ 909b8a36-79bb-4c1a-9dd7-4acaffc0434e
frametitle("Théorème de Bézout")

# ╔═╡ 08b18315-c28e-44ed-beb2-5b17421b0224
md"""
> **Définition** Le *Greatest Common Divisor (GCD)* de deux nombres ``a \in \mathbb{Z}`` et ``b \in \mathbb{Z}``, noté ``\text{gcd}(a, b)`` est le plus grand nombre ``g \in \mathbb{Z}`` qui divise ``a`` et ``b``. C'est à dire qu'il existe ``x \in \mathbb{Z}`` tel que ``a = gx`` et ``y \in \mathbb{Z}`` tel que ``b = gy``. En notation modulaire, ``a \equiv 0 \pmod{g}`` et ``b \equiv 0 \pmod{g}``.

> **Théorème de Bézout** Il existe ``x, y \in \mathbb{Z}`` tels que ``ax + by = c`` si et seulement si ``\text{gcd}(x, y)`` divise ``c``. En notation modulaire ``ax \equiv c \pmod{b}`` et ``by \equiv c \pmod{a}``.
"""

# ╔═╡ 7bad8c6c-45c7-402f-ad59-6857e9268901
qa(md"Comment prouver que l'égalité ``ax + by = c`` implique que ``\text{gcd}(x, y)`` divise ``c`` ?",
md"""
""",)

# ╔═╡ cd481f6c-66f4-4ebf-9769-c3edc24f403b
frametitle("Algorithme d'Euclide : élaboration")

# ╔═╡ 37585789-bd43-4ce5-b550-ad712b70d226
md"""
> **Définition** Le résultat de la *division Euclidienne* de ``a`` par un diviseur ``d`` est un quotient ``q`` et un reste ``0 \le r < d`` tels que ``a = qd + r``. En notation modulaire ``a \equiv r \pmod{d}``.
"""

# ╔═╡ 6e59ee60-ef73-45ca-86eb-4d8a44c73771
qa(md"**Observation clé** Que dit le théorème de Bézout par rapport à ``\text{gcd}(a, d)`` et ``r``.",
md"""
Le reste ``r`` est **divisible** par ``\text{gcd}(a, d)``.
Le nombre ``\text{gcd}(a, d)`` divise donc les 3 nombres, ``a``, ``d`` et ``r`` et donc ``\text{gcd}(a, d) = \text{gcd}(a, d, r)``.
""")

# ╔═╡ d6b89fda-308f-43da-8028-1a812b4516cf
qa(md"**Observation clé** Que dit le théorème de Bézout par rapport à ``\text{gcd}(d, r)`` et ``a``.",
md"""
Le nombre ``a`` est **divisible** par ``\text{gcd}(d, r)``.
Le nombre ``\text{gcd}(d, r)`` divise donc les 3 nombres, ``a``, ``d`` et ``r`` et donc ``\text{gcd}(d, r) = \text{gcd}(a, d, r)``.
En combinant ça avec l'observation précédente, on a le résultat suivant.``\text{gcd}(a, d) = \text{gcd}(d, r)``.
""")

# ╔═╡ d1b260fb-7500-47fb-bb48-21b5857ab55a
md"""
**Lemme**: Si ``a \equiv r \pmod{b}`` alors ``\text{gcd}(a, b) = \text{gcd}(b, r)``.
"""

# ╔═╡ 9207b107-e1b0-4328-a004-f4b8152b423f
qa(md"**Observation clé** Si ``a > b``, trouver un mono-variant.",
md"""
On a ``(a, b) > (b, r)``. En effet, ``a > b`` par supposition et ``b > r`` par définition de l'algorithme d'Euclide.
Notons que même si la supposition ``a > b`` n'est pas vraie, elle le devient pour ``\text{gcd}(b, r)``.
""")

# ╔═╡ 48eba223-6cce-4aa2-9977-4883ba7903fc
qa(md"**Observation finale** Si ``a`` et ``b`` sont positifs et qu'on effectue la substitution ``(a, b) \to (b, r)`` récursivement, le mono-variant impose qu'on ne puisse itérer qu'un nombre fini de fois, que va-t-il se passer ?",
md"""
La paire ``(a, b)`` va diminuer strictement (c'est à dire d'au moins 1) à chaque itération. Pourtant, ce sont des nombres entier positifs donc ils ne peuvent diminuer strictement qu'un nombre fini de fois. C'est une contradiction, comme cela se fait-il ?
À un moment ``b`` vaudra 0, on ne pourra alors plus faire de division Euclidienne. On utilisera alors le fait que ``\text{gcd}(a, 0) = a``.
""")

# ╔═╡ bd0c0258-7040-42e7-a20e-532b55af3a62
frametitle("Algorithme d'Euclide : implémentation")

# ╔═╡ 97736c6a-3f5d-4978-8dd2-0a11c09ba9f0
function pgcd(a, b)
	print("gcd($a, $b) = ")
    if a < b
		return pgcd(b, a)
	elseif b == 0
		println(a)
		return a
	else
		return pgcd(b, mod(a, b))
	end
end

# ╔═╡ 1a4da418-147f-46f4-9b95-7955183aa5cf
md"a = $(@bind a Slider(1:typemax(Int32), default=90284599, show_value = true))"

# ╔═╡ f39cccac-5b24-46e4-8749-1b0a944542ef
md"b = $(@bind b Slider(1:typemax(Int32), default=249357461, show_value = true))"

# ╔═╡ fe2af566-4a8b-4052-9915-85266ee5ce98
pgcd(a, b)

# ╔═╡ 03e49669-cdee-4241-862d-33ee91214455
md"The complexity is difficult to evaluate but can be shown to be ``O(\log(\min(a, b)))``."

# ╔═╡ 83852dd5-3546-45af-a845-b01dab0aa2a6
frametitle("Division modulaire")

# ╔═╡ 352b26e4-1cc3-47d5-a772-b460f718ebf8
frametitle("Inverse modulaire")

# ╔═╡ 2cb5c6e0-b431-4d2e-b023-cd2131112eca
frametitle("Algorithme d'Euclide étendu")

# ╔═╡ f4895654-d684-42d2-ae4c-de72e6824484
frametitle("Euler totient function")

# ╔═╡ f855a589-36c2-4b77-9f01-17da963658f4
mod(2^Primes.totient(11), 11)

# ╔═╡ 457a1da2-3f87-43e6-a9cf-8dbfb225c4dc
frametitle("Fast exponentiation")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Primes = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"

[compat]
PlutoUI = "~0.7.60"
Primes = "~0.5.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.1"
manifest_format = "2.0"
project_hash = "c18f2dc82a5fa9b4f1b8bdf216d21c9674fba955"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "b8ffb903da9f7b8cf695a8bead8e01814aa24b30"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "cb420f77dc474d23ee47ca8d14c90810cafe69e7"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.6"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─736307ec-a2a4-11ef-0f85-ad1a0093e06a
# ╟─cbabee34-2ca2-4ad4-93ba-2ec3c941da5e
# ╟─909b8a36-79bb-4c1a-9dd7-4acaffc0434e
# ╟─08b18315-c28e-44ed-beb2-5b17421b0224
# ╟─7bad8c6c-45c7-402f-ad59-6857e9268901
# ╟─cd481f6c-66f4-4ebf-9769-c3edc24f403b
# ╟─37585789-bd43-4ce5-b550-ad712b70d226
# ╟─6e59ee60-ef73-45ca-86eb-4d8a44c73771
# ╟─d6b89fda-308f-43da-8028-1a812b4516cf
# ╟─d1b260fb-7500-47fb-bb48-21b5857ab55a
# ╟─9207b107-e1b0-4328-a004-f4b8152b423f
# ╟─48eba223-6cce-4aa2-9977-4883ba7903fc
# ╟─bd0c0258-7040-42e7-a20e-532b55af3a62
# ╠═97736c6a-3f5d-4978-8dd2-0a11c09ba9f0
# ╟─1a4da418-147f-46f4-9b95-7955183aa5cf
# ╟─f39cccac-5b24-46e4-8749-1b0a944542ef
# ╠═fe2af566-4a8b-4052-9915-85266ee5ce98
# ╟─03e49669-cdee-4241-862d-33ee91214455
# ╟─83852dd5-3546-45af-a845-b01dab0aa2a6
# ╟─352b26e4-1cc3-47d5-a772-b460f718ebf8
# ╟─2cb5c6e0-b431-4d2e-b023-cd2131112eca
# ╟─f4895654-d684-42d2-ae4c-de72e6824484
# ╠═f855a589-36c2-4b77-9f01-17da963658f4
# ╟─457a1da2-3f87-43e6-a9cf-8dbfb225c4dc
# ╠═06679a09-47d7-4024-8232-4954c08747a0
# ╠═1b1d5c9b-5fc7-480e-9649-e9c44a49c38d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
