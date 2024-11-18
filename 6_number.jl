### A Pluto.jl notebook ###
# v0.20.0

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
using PlutoUI, Primes, DataFrames

# ╔═╡ 1b1d5c9b-5fc7-480e-9649-e9c44a49c38d
include("utils.jl")

# ╔═╡ 736307ec-a2a4-11ef-0f85-ad1a0093e06a
md"# La théorie des nombres"

# ╔═╡ bbc907b1-63f8-435a-badc-11ed88bd6cf5
frametitle("Exemples")

# ╔═╡ cbabee34-2ca2-4ad4-93ba-2ec3c941da5e
md"""
Si tous les mois avaient 30 jours, est-ce qu'il y a des jours de la semaine qui ne seront jamais le premier du mois ?

Reformulation: pour tout nombre ``0 \le j < 7``, existe-t-il ``x`` et ``y`` tels que ``30x = j + 7y``. Notation modulo : ``30x \equiv j \pmod{7}``.

Si tous les ans avaient 365 jours, est-ce qu'il y a des jours de la semaine qui ne seront jamais le 25 Décembre ? Est si tous les ans avaient 366 jours ? Et s'ils avaient 364 jours ?

Reformulation: pour tout nombre ``0 \le j < 7``, existe-t-il ``x`` et ``y`` tels que ``365x = j + 7y``. Notation modulo : ``365x \equiv j \pmod{7}``.
"""

# ╔═╡ 909b8a36-79bb-4c1a-9dd7-4acaffc0434e
frametitle("Théorème de Bézout")

# ╔═╡ 08b18315-c28e-44ed-beb2-5b17421b0224
md"""
> **Définition** Le *Greatest Common Divisor (GCD)* de deux nombres ``a \in \mathbb{Z}`` et ``b \in \mathbb{Z}``, noté ``\text{gcd}(a, b)`` est le plus grand nombre ``g \in \mathbb{Z}`` qui divise ``a`` (noté ``g \mid a``) et ``b`` (noté ``g \mid b``). C'est à dire qu'il existe ``x \in \mathbb{Z}`` tel que ``a = gx`` et ``y \in \mathbb{Z}`` tel que ``b = gy``. En notation modulaire, ``a \equiv 0 \pmod{g}`` et ``b \equiv 0 \pmod{g}``.

> **Théorème de Bézout** Il existe ``x, y \in \mathbb{Z}`` tels que ``ax + by = c`` si et seulement si ``\text{gcd}(a, b)`` divise ``c``. En notation modulaire ``ax \equiv c \pmod{b}`` et ``by \equiv c \pmod{a}``.
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
En combinant ça avec l'observation précédente, on a ``\text{gcd}(a, d) = \text{gcd}(d, r)``. On peut généraliser cela en le lemme suivant:
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
	println("gcd($a, $b) = ")
    if b == 0
		println(a)
		return a
	else
		return pgcd(b, mod(a, b))
	end
end

# ╔═╡ 1a4da418-147f-46f4-9b95-7955183aa5cf
md"`gcd_a` = $(@bind gcd_a Slider(1:typemax(Int32), default=90284599, show_value = true))"

# ╔═╡ f39cccac-5b24-46e4-8749-1b0a944542ef
md"`gcd_b` = $(@bind gcd_b Slider(1:typemax(Int32), default=249357461, show_value = true))"

# ╔═╡ fe2af566-4a8b-4052-9915-85266ee5ce98
pgcd(gcd_a, gcd_b)

# ╔═╡ 03e49669-cdee-4241-862d-33ee91214455
md"The complexity is difficult to evaluate but can be shown to be ``O(\log(\min(a, b)))``."

# ╔═╡ 0ee6972c-5069-4ba0-887f-be64c7d000d0
frametitle("Arithmétique modulaire : somme")

# ╔═╡ f4f49568-dcf2-4c76-ba66-065d2fda7a4a
md"""
```math
a \equiv \alpha \pmod{n} \quad \text{et} \quad b \equiv \beta \pmod{n}
\quad \Rightarrow \quad a + b \equiv \alpha + \beta \pmod{n}
```
"""

# ╔═╡ 09f44611-ba21-4982-ba1b-0691124642fc
frametitle("Arithmétique modulaire : produit")

# ╔═╡ 642d545f-b1b9-49da-8a03-ad63e3214f59
md"""
```math
a \equiv \alpha \pmod{n} \quad \text{et} \quad b \equiv \beta \pmod{n}
\quad \Rightarrow \quad a b \equiv \alpha \beta \pmod{n}
```
"""

# ╔═╡ 7db2060b-d69e-42e7-ae81-fd37ee793876
md"""
Corollaire
```math
n \mid a \quad \text{et} \quad n \mid b \quad \Rightarrow \quad n \mid (ab)
```
À ne pas confondre avec
```math
a \mid n \quad \text{et} \quad b \mid n \quad \Rightarrow \quad (ab/\text{gcd}(a,b)) \mid n
```
"""

# ╔═╡ c3411941-d77f-46cb-8378-23998a1a4828
frametitle("Division par 3 et 9")

# ╔═╡ a826d9d1-47db-4645-be6e-3ae0ed8d4e18
md"""
Est-ce que 2345 est divisible par 3 ou 9?
```math
\begin{align}
2 \cdot 10^3 + 3 \cdot 10^2 + 4 \cdot 10 + 5 & \equiv \,\, ? \pmod{9}\\
2 \cdot 1^3 + 3 \cdot 1^2 + 4 \cdot 1 + 5 & \equiv \,\, ? \pmod{9}\\
2 + 3 + 4 + 5 & \equiv 14 \pmod{9}\\
\end{align}
```
Est-ce que 2345 est divisible par 11?
```math
\begin{align}
2 \cdot (10)^3 + 3 \cdot 10^2 + 4 \cdot 10 + 5 & \equiv \,\, ? \pmod{11}\\
2 \cdot (-1)^3 + 3 \cdot (-1)^2 + 4 \cdot (-1) + 5 & \equiv \,\, ? \pmod{11}\\
-2 + 3 - 4 + 5 & \equiv 2 \pmod{11}\\
\end{align}
```
"""

# ╔═╡ 83852dd5-3546-45af-a845-b01dab0aa2a6
frametitle("Inverse et division modulaire")

# ╔═╡ e1aafab7-c4f3-45ac-81ee-7f875ac7c8c6
md"""
* **Inverse modulaire** : étant donné ``a, n``, trouver ``x`` (noté ``a^{-1}``) tel que ``xa \equiv 1 \pmod{n}``
* **Division modulaire** : étant donné ``a, b, n``, trouver ``x`` tel que ``xa \equiv b \pmod{n}`` → ``x \equiv a^{-1}b \pmod{n}``.


"""

# ╔═╡ 9752afbb-96e6-4f96-92cb-09654cf46155
qa(md"Est-ce que l'inverse modulaire existe toujours ?",
md"""
Par le théorème de Bézout, il existe si et seulement si ``\text{gcd}(a, n) \mid 1``, c'est à dire que ``\text{gcd}(a, n) = 1``.
""")

# ╔═╡ a7985d16-500b-4024-aaa1-78e654b94be4
qa(md"Comment trouver l'inverse modulaire ?",
md"""
Si on avait les coefficients ``x`` et ``y`` tels que ``xa + yn = 1``, l'inverse serait ``x``. Dans l'algorithme d'Euclide, on ne garde que le **reste** et on oublie le **quotient**. Il faudrait combiner les quotients des différentes opérations pour trouver ``x``.
""")

# ╔═╡ 2cb5c6e0-b431-4d2e-b023-cd2131112eca
frametitle("Algorithme d'Euclide étendu")

# ╔═╡ b319619e-8f8d-4650-8fb4-76e5ba953470
md"""
```math
xb + yr = g \quad \text{et} \quad r = a - qb \quad \Rightarrow \quad (x - yq)b + ya = g
```
Solution *homogène* ``x = b``, ``y = -a`` → ``ba - ab = 0``.
Donc si ``(x, y)`` est solution, ``(x + b, y - a)`` aussi.
"""

# ╔═╡ 3f1af973-a02b-4e06-8e6e-eff414fcaf67
function pgcdx(a, b)
    if b == 0
		return a, one(a), zero(a)
	else
		q, r = divrem(a, b)
		g, x, y = pgcdx(b, r)
		return g, y, x - y * q
	end
end

# ╔═╡ aee611f2-bc86-4e85-bbcb-add78c6a9175
gcd_g, gcd_x, gcd_y = pgcdx(gcd_a, gcd_b)

# ╔═╡ 40b8e474-16e0-4a61-bb28-11d90beefeea
gcd_x * gcd_a + gcd_y * gcd_b

# ╔═╡ a41722b8-8c21-4d3c-a38b-4d248a79e80a
md"Pas une solution unique:"

# ╔═╡ eeaec4f4-71bd-43df-b9c9-a00bc3b1864b
gcdx(gcd_a, gcd_b)

# ╔═╡ 2c34c17e-12de-43ea-870c-818c97647836
frametitle("Inversion modulaire par Euclide étendu")

# ╔═╡ ca8905ef-97a3-424c-bb2e-559f7151585b
md"""
Ensemble de solutions: ``(x + kb, y - ka)`` pour un ``k \in \mathbb{Z}`` arbitraire.
Prenons ``k`` tel que ``0 \le x + kb < b`` avec `mod`.
"""

# ╔═╡ 21df1900-3954-4506-b759-aeeee664d1df
function modinv(a, n)
	g, x, y = gcdx(a, n)
	return mod(x, n)
end

# ╔═╡ 819f15ef-31d0-44b6-837a-e3e67f2667b9
md"Revenons aux exemples:"

# ╔═╡ 78df9410-5ea4-4d9f-bbe5-862f76a100fc
md"``30x \equiv j \pmod{7} \quad \Rightarrow \quad x \equiv (30)^{-1} j\pmod{7}``"

# ╔═╡ 93aa2719-f962-497b-9fda-30f54fd848eb
collect(mod.(modinv(30, 7) .* (0:6), 7))

# ╔═╡ 7da0705e-c925-4f8d-9ca4-8d8a0f859fea
md"``365x \equiv j \pmod{7} \quad \Rightarrow \quad x \equiv (365)^{-1} j\pmod{7}``"

# ╔═╡ a59a20e2-a7c7-48a9-ad8d-8094e03a749d
collect(mod.(modinv(365, 7) .* (0:6), 7))

# ╔═╡ e52d25b3-65bf-4617-ae8d-fae0d0c8d041
md"``366x \equiv j \pmod{7} \quad \Rightarrow \quad x \equiv (366)^{-1} j\pmod{7}``"

# ╔═╡ ed3d6ea6-08c9-45d0-8b77-3389a557bfd1
collect(mod.(modinv(366, 7) .* (0:6), 7))

# ╔═╡ bbb2793a-faa4-43bd-b2e8-e8d3ac93310f
md"S'il y avait 364 jours par ans, les fêtes seraient toujours le même jour de la semaine!"

# ╔═╡ f9f03579-5bfc-452d-bff9-9e7adfe095d3
gcd(364, 7)

# ╔═╡ d8a28762-8aab-49e9-b9ac-38901d34abff
frametitle("Fast powering")

# ╔═╡ e505716d-af01-455f-a55a-a9c225822ad5
md"""
Comment calculer ``a^m`` pour un large ``m`` ?
"""

# ╔═╡ a7d06375-e4dd-47b1-8aba-11dc4d62954b
qa(md"Supposons que ``m`` est pair, c'est à dire ``m = 2k``...",
md"""
On a ``a^(2k) = (a^k)^2``. Si ``b = a^k``, on calcule le produit ``b \times b``.
""")

# ╔═╡ 6332b2f2-ed2f-448a-b1df-247b110e335b
qa(md"Que faire si que ``m`` est impair, c'est à dire ``m = 2k + 1``...",
md"""
Si ``b = a^(2k)``, calcule le produit ``b \times a``.
""")

# ╔═╡ 6107d03d-1e45-4eb9-b8e2-51e4a72485e6
frametitle("Recursive implementation")

# ╔═╡ 58da5ba4-c858-4684-a9f4-5a39fdc4fb03
function fast_power(prod_func::Function, a, power)
	if power == 0
		return one(a)
	elseif mod(power, 2) == 1
		return prod_func(fast_power(prod_func, a, power - 1), a)
	else
		b = fast_power(prod_func, a, div(power, 2))
		return prod_func(b, b)
	end
end

# ╔═╡ a4698418-ebf7-4992-a3ba-a15ff282bf87
qa(md"Quelle est la complexité temporelle ?", md"Si ``n`` est impair, au coup suivant, il est pair donc il n'est impair qu'au pire une fois sur deux. En ``l`` multiplication, on divise ``m`` au moins par ``2^{l/2}`` donc on a une complexité logarithmique ``\Theta(\log(m))``  en supposant que `prod_func` a une complexité ``\Theta(1)``.")

# ╔═╡ 59817f59-429b-4f17-a46a-185571fd1e5a
frametitle("Fast modular powering")

# ╔═╡ 8670abc2-63e6-496a-b20c-812197acd9ad
fast_mod_power(a, power, n) = fast_power((a, b) -> mod(a * b, n), a, power)

# ╔═╡ 1b2245f8-2f02-4c4d-b6d2-e65af1f2a21e
md"Last 3 digit:"

# ╔═╡ 9722971a-16f1-4f28-ba31-c12b673b8a30
md"Et modulo 999 ?"

# ╔═╡ 6ed7c73d-60da-4908-85cb-958745d81ebc
md"Par l'algo d'Euclide, ``\text{gcd}(n, n - 1) = 1`` donc ``\text{gcd}(1000, 999) = 1``."

# ╔═╡ 9d4858f8-e63d-46e0-a6cc-992d3cc4a9a4
qa(md"Comment trouver `mod(2^power, 999000)` en utilisant `pow_1000` et `pow_999` ?", md"
On peut utiliser une astuce similaire à l'interpolation Lagrangienne.
On veut trouver ``x`` et ``y`` tels que
```math
\texttt{pow\_1000}x + \texttt{pow\_999}y \equiv 2^\texttt{power} \pmod{999000}
```
On veut que ``x \equiv 0 \pmod{999}`` et ``x \equiv 1 \pmod{1000}``.
On utilise donc ``x = 999x'`` avec ``x' \equiv (999)^{-1} \pmod{1000}``.
")

# ╔═╡ c2fab245-8a98-4b41-ade2-c5b16e9c39f9
frametitle("Chinese remainder theorem")

# ╔═╡ 821de132-559b-4420-b866-e97134c5bd9a
function chinese_remainder_theorem(r, n)
	for i in eachindex(n)
		for j in eachindex(n)
			if i != j && gcd(n[i], n[j]) != 1
				error("`$(n[i])` and `$(n[j])` are not coprime")
			end
		end
	end
	prod_n = prod(n)
	return mod(sum(eachindex(n)) do i
		m = div(prod_n, n[i])
		return mod(r[i] * mod(m * modinv(m, n[i]), prod_n), prod_n)
	end, prod_n)
end

# ╔═╡ 67093a35-8e1b-4cd3-b11b-c7ff601f802e
md"`primes_upper` = $(@bind primes_upper Slider(50:300, default = 100, show_value = true))"

# ╔═╡ 16b677e4-c467-462a-b770-b7a31160e129
prime_list = primes(3, primes_upper)

# ╔═╡ 61462af5-69bd-42be-8918-7992c79ee00d
qa(md"Comment savoir si `prime_list` contient assez de nombres pour avoir la bonne réponse ?", md"On a la bonne réponse modulo `prod(prime_list)` donc si `prod(prime_list) > 2^power`, on a la bonne réponse.")

# ╔═╡ 8f6ba1c4-a971-4dc4-ac5d-2f30790aecde
frametitle("Fermat’s Little Theorem")

# ╔═╡ 82ba8fe1-435e-422b-abb7-cb50a7a85e1e
frametitle("Dicrete logarithm")

# ╔═╡ a293bb0e-078d-4335-a446-3096a79c03bc
frametitle("Diffie-Hellman")

# ╔═╡ 3da58487-192f-458a-9d47-7a4ce98b6da3
section("Utils")

# ╔═╡ bafc9870-3823-4d1d-b0b7-94c69ee764d5
import DocumenterCitations

# ╔═╡ b57adc77-3783-4958-91a0-e90782338755
slider_a = @bind a Slider(1:100, default=11, show_value = true)

# ╔═╡ 18031ccb-657f-409a-9080-9a0ada3ae8b5
slider_b = @bind b Slider(1:100, default=13, show_value = true)

# ╔═╡ 256c8009-4d2b-42f8-adaa-6f238ef22c6d
slider_n = @bind n Slider(1:100, default=5, show_value = true)

# ╔═╡ 31388128-33a3-4443-835e-74b91bf48268
mod(a + b, n)

# ╔═╡ 87fdefa1-3bbd-4b69-ad3a-72baca6e55ee
mod(mod(a, n) + mod(b, n), n)

# ╔═╡ a1628317-7937-4316-85bf-2da860effce3
mod(a * b, n)

# ╔═╡ 5c6c45b4-67e3-4ea8-bc09-0205ab24cbc3
mod(mod(a, n) * mod(b, n), n)

# ╔═╡ 4e35d650-b9a6-4668-90f0-f27a50af29ad
abn_picker = md"""
| `a` | ``\alpha`` | `b` | ``\beta`` | `n` |
|------|-----|-----|---|---|
| $slider_a | $(mod(a, n)) | $slider_b | $(mod(b, n)) | $slider_n |
"""

# ╔═╡ d81bbd74-42df-4bb2-a045-9c2642cc19e5
abn_picker

# ╔═╡ 4ef2c7e9-fb37-4e38-a252-b9c3f83d2a82
abn_picker

# ╔═╡ 2381babe-0777-45db-acff-cc647a8a68d3
power_slider = @bind power Slider(1:10000, default = 256, show_value = true)

# ╔═╡ c8f85081-3659-4796-8550-2e708b09c8d7
md"`power` = $power_slider"

# ╔═╡ 7881bb75-3ef9-496e-860b-03ced6b593c5
@time big(2)^power

# ╔═╡ 087cbe82-b42a-4f80-a1af-97f3aa93aeeb
md"`power` = $power_slider"

# ╔═╡ 9e8a61d9-a700-4851-b1cd-49ce042c3530
@time big(2)^power

# ╔═╡ 3c198d79-c46a-4781-8bd1-b6b68f06c31f
@time fast_power(*, big(2), power)

# ╔═╡ 77093b36-c232-4477-be49-845f1a631829
@time pow_1000 = fast_mod_power(2, power, 1000)

# ╔═╡ 65f4990f-1952-4682-8fa8-9e3dd4bf1ebf
@time pow_999 = fast_mod_power(2, power, 999)

# ╔═╡ 6f10de7b-ce05-4f82-82e7-4110be44e8cc
mod(pow_1000 * 999 * modinv(999, 1000) + pow_999 * 1000 * modinv(1000, 999), 999000)

# ╔═╡ ec25ce2a-de8a-4b69-a3f3-b47cd58ec986
chinese_remainder_theorem([pow_1000, pow_999], [1000, 999])

# ╔═╡ 9cef898e-192c-418a-bec6-511f8b6da179
fast_mod_power(2, power, 999000)

# ╔═╡ 191f8429-cbbb-44aa-8beb-271a94293e4b
chinese_remainder_theorem(big.(fast_mod_power.(2, power, prime_list)), big.(prime_list))

# ╔═╡ e9633e3f-376d-413d-bc19-d015f6ce76e5
big(2)^power

# ╔═╡ ba16d83d-21a5-4f0c-807b-674a167da4dc
biblio = load_biblio!()

# ╔═╡ 6c3595d2-4f68-44da-90e7-dc9c68479bcf
cite(args...) = bibcite(biblio, args...)

# ╔═╡ 3df688c8-1c52-462d-88be-daa153333c60
md"""
* Théorie des nombres: $(cite("hoffstein2014Introduction", "1.2, 1.3, 1.4, 1.5, 2.2, 2.3"))
* Diffie-Hellman: $(cite("hoffstein2014Introduction", "2.2, 2.3"))
"""

# ╔═╡ ed023033-1044-4d48-aab1-39e9300043f7
cite("hoffstein2014Introduction", "Theorem 1.24")

# ╔═╡ 8a5a251f-5373-445a-97b1-4d652c6b7ba8
refs(keys) = bibrefs(biblio, keys)

# ╔═╡ 41cf9efd-65e5-4abb-94d3-e824780e659c
refs(["hoffstein2014Introduction"])

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DocumenterCitations = "daee34ce-89f3-4625-b898-19384cb65244"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Primes = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"

[compat]
DataFrames = "~1.7.0"
DocumenterCitations = "~1.3.5"
PlutoUI = "~0.7.60"
Primes = "~0.5.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.1"
manifest_format = "2.0"
project_hash = "39cd322a83db7ad72fd4bf305476ad8bef3b75b5"

[[deps.ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BibInternal]]
deps = ["TestItems"]
git-tree-sha1 = "b3107800faf461eca3281f89f8d768f4b3e99969"
uuid = "2027ae74-3657-4b95-ae00-e2f7d55c3e64"
version = "0.3.7"

[[deps.BibParser]]
deps = ["BibInternal", "DataStructures", "Dates", "JSONSchema", "TestItems", "YAML"]
git-tree-sha1 = "33478bed83bd124ea8ecd9161b3918fb4c70e529"
uuid = "13533e5b-e1c2-4e57-8cef-cac5e52f6474"
version = "0.2.2"

[[deps.Bibliography]]
deps = ["BibInternal", "BibParser", "DataStructures", "Dates", "FileIO", "YAML"]
git-tree-sha1 = "520c679daed011ce835d9efa7778863aad6687ed"
uuid = "f1be7e48-bf82-45af-a471-ae754a193061"
version = "0.2.20"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "fb61b4812c49343d7ef0b533ba982c46021938a6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.7.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Documenter]]
deps = ["ANSIColoredPrinters", "AbstractTrees", "Base64", "CodecZlib", "Dates", "DocStringExtensions", "Downloads", "Git", "IOCapture", "InteractiveUtils", "JSON", "LibGit2", "Logging", "Markdown", "MarkdownAST", "Pkg", "PrecompileTools", "REPL", "RegistryInstances", "SHA", "TOML", "Test", "Unicode"]
git-tree-sha1 = "d0ea2c044963ed6f37703cead7e29f70cba13d7e"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "1.8.0"

[[deps.DocumenterCitations]]
deps = ["AbstractTrees", "Bibliography", "Dates", "Documenter", "Logging", "Markdown", "MarkdownAST", "OrderedCollections", "Unicode"]
git-tree-sha1 = "5a72f3f804deb1431cb79f5636163e4fdf8ed8ed"
uuid = "daee34ce-89f3-4625-b898-19384cb65244"
version = "1.3.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c6317308b9dc757616f0b5cb379db10494443a7"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.2+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "91e0e5c68d02bcdaae76d3c8ceb4361e8f28d2e9"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.5"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.Git]]
deps = ["Git_jll"]
git-tree-sha1 = "04eff47b1354d702c3a85e8ab23d539bb7d5957e"
uuid = "d7ba0133-e1db-5d97-8f8c-041e4b3a1eb2"
version = "1.3.1"

[[deps.Git_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "LibCURL_jll", "Libdl", "Libiconv_jll", "OpenSSL_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "ea372033d09e4552a04fd38361cd019f9003f4f4"
uuid = "f8c6e375-362e-5223-8a59-34ff63f689eb"
version = "2.46.2+0"

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

[[deps.InlineStrings]]
git-tree-sha1 = "45521d31238e87ee9f9732561bfee12d4eebd52d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.2"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "b8ffb903da9f7b8cf695a8bead8e01814aa24b30"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "be3dc50a92e5a386872a493a10050136d4703f9b"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "1d322381ef7b087548321d3f878cb4c9bd8f8f9b"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.1"

    [deps.JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [deps.JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JSONSchema]]
deps = ["Downloads", "JSON", "JSON3", "URIs"]
git-tree-sha1 = "243f1cdb476835d7c249deb9f29ad6b7827da7d3"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "1.4.1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.LazilyInitializedFields]]
git-tree-sha1 = "0f2da712350b020bc3957f269c9caad516383ee0"
uuid = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
version = "1.3.0"

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

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "61dfdba58e585066d8bce214c5a51eaa0539f269"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+1"

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

[[deps.MarkdownAST]]
deps = ["AbstractTrees", "Markdown"]
git-tree-sha1 = "465a70f0fc7d443a00dcdc3267a497397b8a3899"
uuid = "d0879d2d-cac2-40c8-9cee-1863dc0c7391"
version = "0.1.2"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

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

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7493f61f55a6cce7325f197443aa80d32554ba10"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+1"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

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

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "1101cd475833706e4d0e7b122218257178f48f34"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.4.0"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "cb420f77dc474d23ee47ca8d14c90810cafe69e7"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.6"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegistryInstances]]
deps = ["LazilyInitializedFields", "Pkg", "TOML", "Tar"]
git-tree-sha1 = "ffd19052caf598b8653b99404058fce14828be51"
uuid = "2792f1a3-b283-48e8-9a74-f99dce5104f3"
version = "0.1.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "d0553ce4031a081cc42387a9b9c8441b7d99f32d"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.7"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StringEncodings]]
deps = ["Libiconv_jll"]
git-tree-sha1 = "b765e46ba27ecf6b44faf70df40c57aa3a547dcb"
uuid = "69024149-9ee7-55f6-a4c4-859efe599b68"
version = "0.3.7"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a6b1675a536c5ad1a60e5a5153e1fee12eb146e3"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.0"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "159331b30e94d7b11379037feeb9b690950cace8"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.11.0"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TestItems]]
git-tree-sha1 = "42fd9023fef18b9b78c8343a4e2f3813ffbcefcb"
uuid = "1c621080-faea-4a02-84b6-bbd5e436b8fe"
version = "1.0.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

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

[[deps.YAML]]
deps = ["Base64", "Dates", "Printf", "StringEncodings"]
git-tree-sha1 = "dea63ff72079443240fbd013ba006bcbc8a9ac00"
uuid = "ddb6d928-2868-570f-bddf-ab3f9cf99eb6"
version = "0.4.12"

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
# ╟─3df688c8-1c52-462d-88be-daa153333c60
# ╟─41cf9efd-65e5-4abb-94d3-e824780e659c
# ╟─bbc907b1-63f8-435a-badc-11ed88bd6cf5
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
# ╟─0ee6972c-5069-4ba0-887f-be64c7d000d0
# ╟─f4f49568-dcf2-4c76-ba66-065d2fda7a4a
# ╟─d81bbd74-42df-4bb2-a045-9c2642cc19e5
# ╠═31388128-33a3-4443-835e-74b91bf48268
# ╠═87fdefa1-3bbd-4b69-ad3a-72baca6e55ee
# ╟─09f44611-ba21-4982-ba1b-0691124642fc
# ╟─642d545f-b1b9-49da-8a03-ad63e3214f59
# ╟─4ef2c7e9-fb37-4e38-a252-b9c3f83d2a82
# ╠═a1628317-7937-4316-85bf-2da860effce3
# ╠═5c6c45b4-67e3-4ea8-bc09-0205ab24cbc3
# ╟─7db2060b-d69e-42e7-ae81-fd37ee793876
# ╟─c3411941-d77f-46cb-8378-23998a1a4828
# ╟─a826d9d1-47db-4645-be6e-3ae0ed8d4e18
# ╟─83852dd5-3546-45af-a845-b01dab0aa2a6
# ╟─e1aafab7-c4f3-45ac-81ee-7f875ac7c8c6
# ╟─9752afbb-96e6-4f96-92cb-09654cf46155
# ╟─a7985d16-500b-4024-aaa1-78e654b94be4
# ╟─2cb5c6e0-b431-4d2e-b023-cd2131112eca
# ╟─b319619e-8f8d-4650-8fb4-76e5ba953470
# ╠═3f1af973-a02b-4e06-8e6e-eff414fcaf67
# ╠═aee611f2-bc86-4e85-bbcb-add78c6a9175
# ╠═40b8e474-16e0-4a61-bb28-11d90beefeea
# ╟─a41722b8-8c21-4d3c-a38b-4d248a79e80a
# ╠═eeaec4f4-71bd-43df-b9c9-a00bc3b1864b
# ╟─2c34c17e-12de-43ea-870c-818c97647836
# ╟─ca8905ef-97a3-424c-bb2e-559f7151585b
# ╠═21df1900-3954-4506-b759-aeeee664d1df
# ╟─819f15ef-31d0-44b6-837a-e3e67f2667b9
# ╟─78df9410-5ea4-4d9f-bbe5-862f76a100fc
# ╠═93aa2719-f962-497b-9fda-30f54fd848eb
# ╟─7da0705e-c925-4f8d-9ca4-8d8a0f859fea
# ╠═a59a20e2-a7c7-48a9-ad8d-8094e03a749d
# ╟─e52d25b3-65bf-4617-ae8d-fae0d0c8d041
# ╠═ed3d6ea6-08c9-45d0-8b77-3389a557bfd1
# ╟─bbb2793a-faa4-43bd-b2e8-e8d3ac93310f
# ╠═f9f03579-5bfc-452d-bff9-9e7adfe095d3
# ╟─d8a28762-8aab-49e9-b9ac-38901d34abff
# ╟─e505716d-af01-455f-a55a-a9c225822ad5
# ╟─c8f85081-3659-4796-8550-2e708b09c8d7
# ╠═7881bb75-3ef9-496e-860b-03ced6b593c5
# ╟─a7d06375-e4dd-47b1-8aba-11dc4d62954b
# ╟─6332b2f2-ed2f-448a-b1df-247b110e335b
# ╟─6107d03d-1e45-4eb9-b8e2-51e4a72485e6
# ╠═58da5ba4-c858-4684-a9f4-5a39fdc4fb03
# ╟─087cbe82-b42a-4f80-a1af-97f3aa93aeeb
# ╠═9e8a61d9-a700-4851-b1cd-49ce042c3530
# ╠═3c198d79-c46a-4781-8bd1-b6b68f06c31f
# ╟─a4698418-ebf7-4992-a3ba-a15ff282bf87
# ╟─59817f59-429b-4f17-a46a-185571fd1e5a
# ╠═8670abc2-63e6-496a-b20c-812197acd9ad
# ╟─1b2245f8-2f02-4c4d-b6d2-e65af1f2a21e
# ╠═77093b36-c232-4477-be49-845f1a631829
# ╟─9722971a-16f1-4f28-ba31-c12b673b8a30
# ╠═65f4990f-1952-4682-8fa8-9e3dd4bf1ebf
# ╟─6ed7c73d-60da-4908-85cb-958745d81ebc
# ╟─9d4858f8-e63d-46e0-a6cc-992d3cc4a9a4
# ╠═9cef898e-192c-418a-bec6-511f8b6da179
# ╠═6f10de7b-ce05-4f82-82e7-4110be44e8cc
# ╟─c2fab245-8a98-4b41-ade2-c5b16e9c39f9
# ╠═821de132-559b-4420-b866-e97134c5bd9a
# ╠═ec25ce2a-de8a-4b69-a3f3-b47cd58ec986
# ╟─67093a35-8e1b-4cd3-b11b-c7ff601f802e
# ╠═16b677e4-c467-462a-b770-b7a31160e129
# ╠═191f8429-cbbb-44aa-8beb-271a94293e4b
# ╠═e9633e3f-376d-413d-bc19-d015f6ce76e5
# ╟─61462af5-69bd-42be-8918-7992c79ee00d
# ╟─8f6ba1c4-a971-4dc4-ac5d-2f30790aecde
# ╟─ed023033-1044-4d48-aab1-39e9300043f7
# ╟─82ba8fe1-435e-422b-abb7-cb50a7a85e1e
# ╟─a293bb0e-078d-4335-a446-3096a79c03bc
# ╟─3da58487-192f-458a-9d47-7a4ce98b6da3
# ╠═06679a09-47d7-4024-8232-4954c08747a0
# ╠═bafc9870-3823-4d1d-b0b7-94c69ee764d5
# ╠═b57adc77-3783-4958-91a0-e90782338755
# ╠═18031ccb-657f-409a-9080-9a0ada3ae8b5
# ╠═256c8009-4d2b-42f8-adaa-6f238ef22c6d
# ╟─4e35d650-b9a6-4668-90f0-f27a50af29ad
# ╠═2381babe-0777-45db-acff-cc647a8a68d3
# ╠═1b1d5c9b-5fc7-480e-9649-e9c44a49c38d
# ╠═ba16d83d-21a5-4f0c-807b-674a167da4dc
# ╠═6c3595d2-4f68-44da-90e7-dc9c68479bcf
# ╠═8a5a251f-5373-445a-97b1-4d652c6b7ba8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
