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

# ╔═╡ 9f027cde-dba0-4da5-8c42-5fa79b3929d6
using Graphs, GraphPlot, Printf

# ╔═╡ f1ba3d3c-d0a5-4290-ab73-9ce34bd5e5f6
using Plots, OneHotArrays, PlutoUI

# ╔═╡ 77a7de14-87d2-11ef-21ef-937b8239db5b
md"""
# Automatic Differentiation

On peut calculer des dérivées partielles de différentes manières:
1. De façon symbolique, en fixant une des variables et en dérivant les autres soit à la main, soit par ordinateur.
2. De façon numérique, avec la formule ``f'(x) \approx (f(x + h) - f(x)) / h``.
3. De façon algorithmique, soit forward, soit reverse, c'est ce que nous verons ici.

Pour illustrer, nous utiliserons l'exemple de classification de points de deux formes de lunes.
"""

# ╔═╡ 677a40de-ef6d-4a41-84f6-05ef6580aeba
md"Nous travaillerons avec une matrice `X` contenant dans chaque ligne, les coordonnées d'un point."

# ╔═╡ 0325e4a5-f50d-4064-b558-9f6275d4cd5a
md"Le vecteur `y` contiendra `1` pour les points de la lune bleue et `-1` pour les points de la lune rouge."

# ╔═╡ 860acc4a-f9ee-49c1-a6d1-d81a3c51d9a8
md"Nous illustrons le calcul de dérivée automatique par l'entrainement du modèle linéaire ``y \approx X w``. Commençons avec des poids aléatoires. Le modèle n'est pour le moment pas très précis comme il est aléatoire."

# ╔═╡ 55a0a91d-ebe4-4d8a-a094-b6e0aeec4587
w = rand(2)

# ╔═╡ c5b0cb9c-40be-44f6-9173-5a0631ab8834
md"En effet, les prédictions ne correspondent pas à `y`."

# ╔═╡ b4d2b635-bbb3-4024-877b-a96fdd19349e
md"On peut regrouper les erreurs des estimations de tous les points en les comparant avec `y`."

# ╔═╡ af404768-0663-4bc3-81dd-6931b3a486be
md"Essayons de trouver des poids `w` qui minimisent la somme des carrés des erreurs (aka MSE):"

# ╔═╡ 277bd2ce-fa7f-4288-be8a-0ddd8f23635c
md"""
## Forward Differentiation

Commençons par définir la forward differentiation. Cette différentiation algorithmique se base sur l'observation que la chain rule permet de calculer la dérivée de n'importe quelle fonction dès lors qu'on connait sont gradient et la dérivée de chacun de ses paramètres.
En d'autres mots, supposons qu'on doive calculer
```math
\frac{\partial}{\partial x} f(g(x), h(x))
```
Supposons que la fonction `f` soit une fonction `f(a, b)` simple (telle que `+`, `*`, `-`) dont on connait la formules des dérivée partielles ``\partial f / \partial a`` en fonction de `a` et ``\partial f / \partial b`` en fonction de `b`:
La chain rule nous donne
```math
\frac{\partial}{\partial x} f(g(x), h(x)) = \frac{\partial f}{\partial a}(g(x), h(x)) \frac{\partial g}{\partial x} + \frac{\partial f}{\partial b}(g(x), h(x)) \frac{\partial h}{\partial x}
```
Pour calculer cette expression, ils nous faut les valeurs de ``g(x)`` et ``h(x)`` ainsi que les dérivées ``\partial g / \partial x`` et ``\partial h / \partial x``.
"""

# ╔═╡ 94f2f9ef-9467-4781-9dfb-f0a32141f542
begin
	struct Dual{T}
   		value::T
   		derivative::T
	end
	Dual(x, y) = Dual{typeof(x)}(x, convert(typeof(x), y))
end

# ╔═╡ e001e562-901f-4afa-a5ad-9bbecdae1694
md"L'implémentation générique du produit de matrice va appeler `zero`:"

# ╔═╡ ea2a923b-df68-4cb8-a3ff-62b0aadcc4f2
Base.zero(::Dual{T}) where {T} = Dual(zero(T), zero(T))

# ╔═╡ e8d8219d-1119-4f81-bc85-b27e33383fff
md"Par linéarité de la dérivée:"

# ╔═╡ 82ccdf44-5c45-4d55-ac1d-f4ec0a146b29
begin
	Base.:*(α::T, x::Dual{T}) where {T} = Dual(α * x.value, α * x.derivative)
	Base.:*(x::Dual{T}, α::T) where {T} = Dual(x.value * α, x.derivative * α)
	Base.:+(x::Dual{T}, y::Dual{T}) where {T} = Dual(x.value + y.value, x.derivative + y.derivative)
	Base.:-(x::Dual{T}, y::T) where {T} = Dual(x.value - y, x.derivative)
	Base.:/(x::Dual, α::Number) = Dual(x.value / α, x.derivative / α)
end

# ╔═╡ 80356507-0b92-4c62-8bdf-865e345a29dc
md"Par la product rule ``(fg)' = f'g + fg'``:"

# ╔═╡ c0caef28-d59a-43a1-af4f-6756c3b41903
md"Pour l'exponentiation, on peut juste se rabatter sur le produit qu'on a déjà défini:"

# ╔═╡ a2ac721c-700e-4bbf-8c13-3b06db292c00
Base.:^(x::Dual, n::Integer) = Base.power_by_squaring(x, n)

# ╔═╡ 3f7cfa28-b060-4a3e-b61a-fd42be8e6939
onehot(1, 1:2)

# ╔═╡ 7d805d6a-9077-4d97-a0db-c1bd306cbbb8
float.(onehot(1, 1:2))

# ╔═╡ 7dfc8a90-5a7d-4457-b382-f9552e02fd73
float.(onehot(2, 1:2))

# ╔═╡ 42eacb3a-54b0-43e8-97a1-07a71ac3faf5
Dual.(w, onehot(1, 1:2))

# ╔═╡ 42f15c09-49f7-40e0-8892-0ade61a3c923
function forward_diff(loss, w, X, y, i)
	loss(Dual.(w, onehot(i, eachindex(w))), X, y).derivative
end

# ╔═╡ 4dde16bc-2c40-4214-8963-2d7a7287f587
function forward_diff(loss, w, X, y)
	[forward_diff(loss, w, X, y, i) for i in eachindex(w)]
end

# ╔═╡ b7303267-3404-4542-a7f8-5960859abc19
md"""
## Gradient descent

### Cauchy-Schwarz inequality

```math
\begin{align}
  \left(\sum_i x_i y_i\right)^2 & = \left(\sum_i x_i^2\right)\left(\sum_i y_i^2\right)\cos(\theta)^2\\
  \sum_i x_i y_i & = \sqrt{\sum_i x_i^2}\sqrt{\sum_i y_i^2}\cos(\theta)\\
  \langle x, y \rangle & = \|x\|_2 \|y\|_2\cos(\theta)\\
  -\|x\|_2 \|y\|_2 \le \langle x, y \rangle & \le \|x\|_2 \|y\|_2
\end{align}
```
Minimum atteint lorsque ``x = -y`` et maximum atteint lorsque ``x = y``.
Dans les deux cas, ``x`` est **parallèle** à ``y``, mais ce sont des **sens** différents.

### Rappel dérivée directionnelle

Dérivée dans la direction ``d``:

```math
\langle d, \nabla f \rangle
=
d^\top \nabla f
=
d_1 \cdot \partial f/\partial x_1 + \cdots + d_n \cdot \partial f/\partial x_n
```
Etant donné un gradient ``\nabla f``, la direction ``d`` telle que ``\|d\|_2 = 1`` qui a une dérivée minmale est ``d = -\nabla f``.
"""

# ╔═╡ b025aa9e-1137-4201-b7b8-2b803f8aa17e
md"Gradient:"

# ╔═╡ 0b4d8741-e9fb-40e4-a8be-cf21683b8f79
md"Gradient line search: pendant combien de temps doit-on suivre le gradient ?"

# ╔═╡ 53fe00ff-32d1-4c61-ae89-e54df5efc3a0
@bind num_η Slider(5:50, default=10, show_value = true)

# ╔═╡ 7ad77ed6-de39-430e-9e71-1c3d37ce7f34
step_sizes = range(-1, stop=1, length=num_η)

# ╔═╡ 52a049a9-c50f-426c-83e5-4ec02d5a638c
md"`num_iters` = $(@bind num_iters Slider(1:20, default = 10, show_value = true))"

# ╔═╡ b1aa765e-7a6b-4ab4-af83-ab3d30497866
md"## Kernel trick"

# ╔═╡ f71923d4-fbc9-4ce6-b5be-a00437c3651d
md"`η_lift` = $(@bind η_lift Slider(exp10.(-4:0.25:1), default=0.01, show_value = true))"

# ╔═╡ 18edd949-ce86-431a-a19b-4daf526e57a6
md"`num_iters_lift` = $(@bind num_iters_lift Slider(1:400, default=200, show_value = true))"

# ╔═╡ dc4feb58-d2cf-4a97-aaed-7f4593fc9732
md"""
### L1 norm

La fonction ``|x|`` n'est pas différentiable lorsque ``x = 0``.
Si on s'approche par la gauche (c'est à dire ``x < 0``, la fonction est ``-x``) donc la dérivée vaut ``-1``.
Si on s'approche par la droite (c'est à dire ``x > 0``, la fonction est ``x``) donc la dérivée vaut ``1``.
Il n'y a pas de gradient valide!
Par contre, n'importe quel nombre entre ``-1`` et ``1`` est un **subgradient** valide ! Alors que le gradient est la normale à la tangente **unique**, le subgradient est un élément du **cone tangent**.
"""

# ╔═╡ f5749121-8e75-45de-95b9-63fff584e350
md"`η_L1` = $(@bind η_L1 Slider(exp10.(-4:0.25:1), default=0.1, show_value = true))"

# ╔═╡ 66e36fb8-5a61-49a7-8053-911fd887b0a9
md"`num_iters_L1` = $(@bind num_iters_L1 Slider(1:400, default=200, show_value = true))"

# ╔═╡ db28bb45-3418-4080-a0fc-9136fc0196a5
md"""
## Reverse diff

Le désavantage de la forward differentiation, c'est qu'il faut recommencer tout le calcul pour calculer la dérivée par rapport à chaque variable. La *reverse differentiation*, aussi appelée *backpropagation*, résoud se problème en calculer la dérivée par rapport à toutes les variables en une fois!

### Chain rule

#### Exemple univarié

Commençons par un exemple univarié pour introduire le fait qu'il existe un choix dans l'ordre de la multiplication des dérivées. La liberté introduite par ce choix donne lieu à la différence entre la différentiation *forward* et *reverse*.

Supposions qu'on veuille dériver la fonction ``\tan(\cos(\sin(x)))`` pour ``x = \pi/3``. La Chain Rule nous donne:
```math
\begin{align}
  (\tan(\cos(\sin(x))))'
  & = \left. (\tan(x))' \right|_{x = \cos(\sin(x)))} (\cos(\sin(x))))'\\
  & = \left. (\tan(x))' \right|_{x = \cos(\sin(x)))}
  \left. (\cos(x))' \right|_{x = \sin(x))}
  (\sin(x)))'\\
  & = \frac{1}{\cos^2(\cos(\sin(x)))} (-\sin(\sin(x))) \cos(x)
\end{align}
```
La dérivée pour ``x = \pi/3`` est donc:
```math
\begin{align}
\left. (\tan(\cos(\sin(x))))' \right|_{x = \pi/3}
& =
\left. (\tan(x))' \right|_{x = \cos(\sin(\pi/3)))}
\left. (\cos(x))' \right|_{x = \sin(\pi/3))}
\left. (\sin(x)))' \right|_{x = \pi/3}\\
& = \frac{1}{\cos^2(\cos(\sin(\pi/3)))} (-\sin(\sin(\pi/3))) \cos(\pi/3)
\end{align}
```
Pour calculer ce produit de 3 nombres, on a 2 choix.

La première possibilité (qui correspond à forward diff) est de commencer par calculer le produit
```math
\begin{align}
\left. (\cos(\sin(x)))' \right|_{x = \pi/3}
& =
\left. (\cos(x))' \right|_{x = \sin(\pi/3))}
\left. (\sin(x)))' \right|_{x = \pi/3}\\
& =
(-\sin(\sin(\pi/3))) \cos(\pi/3)
\end{align}
```
puis de le multiplier avec ``\left. (\tan(x))' \right|_{x = \cos(\sin(\pi/3)))} = \frac{1}{\cos^2(\cos(\sin(\pi/3)))}``.

La deuxième possibilité (qui correspond à reverse diff) est de commencer par calculer le produit
```math
\begin{align}
\left. (\tan(\cos(x)))' \right|_{\textcolor{red}{x = \sin(\pi/3)}}
& =
\left. (\tan(x))' \right|_{\textcolor{red}{x = \cos(\sin(\pi/3)))}}
\left. (\cos(x))' \right|_{\textcolor{red}{x = \sin(\pi/3))}}\\
& = \frac{1}{\cos^2(\cos(\sin(\pi/3)))} (-\sin(\sin(\pi/3)))
\end{align}
```
puis de le multiplier avec ``\cos(\pi/3)``.

Vous remarquerez que dans l'équation ci-dessus, comme mis en évidence en rouge, les valeurs auxquelles les dérivées doivent être évaluées dépendent de ``\sin(\pi/3)``.
L'approche utilisée par reverse diff de multiplier de gauche à droite ne peut donc pas être effectuer sans prendre en compte la valeur qui doit être évaluée de droite à gauche.

Pour appliquer reverse diff, il faut donc commencer par une *forward pass* de droite à gauche qui calcule ``\sin(\pi/3)`` puis ``\cos(\sin(\pi/3))`` puis ``\tan(\cos(\sin(\pi/3)))``. On peut ensuite faire la *backward pass* qui multipliée les dérivée de gauche à droite. Afin d'être disponibles pour la backward pass, les valeurs calculées lors de la forward pass doivent être **stockées** ce qui implique un **coût mémoire**.
En revanche, comme forward diff calcule la dérivée dans le même sens que l'évaluation, les dérivées et évaluations peuvent être calculées en même temps afin de ne pas avoir besoin de stocker les évaluations. C'est effectivement ce qu'on a implémenter avec `Dual` précédemment.

Au vu de ce coût mémoire supplémentaire de reverse diff par rapport à forward diff,
ce dernier paraît préférable en pratique.
On va voir maintenant que dans le cas multivarié, dans certains cas, ce désavantage est contrebalancé par une meilleure complexité temporelle qui rend reverse diff indispensable!
"""

# ╔═╡ 494fc7d7-c622-41d1-91d8-3dc1fbd2f244
md"""
#### Exemple multivarié

Prenons maintenant un example multivarié, supposons qu'on veuille calculer le gradient de la fonction ``f(g(h(x_1, x_2)))`` qui compose 3 fonctions ``f``, ``g`` et ``h``.
Le gradient est obtenu via la chain rule comme suit:
```math
\begin{align}
\frac{\partial}{\partial x_1} f(g(h(x_1, x_2)))
& = \frac{\partial f}{\partial g} \frac{\partial g}{\partial h} \frac{\partial h}{\partial x_1}\\
\frac{\partial}{\partial x_2} f(g(h(x_1, x_2)))
& = \frac{\partial f}{\partial g} \frac{\partial g}{\partial h} \frac{\partial h}{\partial x_2}\\
\nabla_{x_1, x_2} f(g(h(x_1, x_2)))
& = \begin{bmatrix}
\frac{\partial f}{\partial g} \frac{\partial g}{\partial h} \frac{\partial h}{\partial x_1} &
\frac{\partial f}{\partial g} \frac{\partial g}{\partial h} \frac{\partial h}{\partial x_2}
\end{bmatrix}\\
& =
\begin{bmatrix}
\frac{\partial f}{\partial g}
\end{bmatrix}
\begin{bmatrix}
\frac{\partial g}{\partial h}
\end{bmatrix}
\begin{bmatrix}
\frac{\partial h}{\partial x_1} &
\frac{\partial h}{\partial x_2}
\end{bmatrix}
\end{align}
```
On voit que c'est le produit de 3 matrices. Forward diff va exécuter ce produit de droite à gauche:
```math
\begin{align}
\nabla_{x_1, x_2} f(g(h(x_1, x_2)))
& =
\begin{bmatrix}
\frac{\partial f}{\partial g}
\end{bmatrix}
\begin{bmatrix}
\frac{\partial g}{\partial h}\frac{\partial h}{\partial x_1} &
\frac{\partial g}{\partial h}\frac{\partial h}{\partial x_2}
\end{bmatrix}\\
& =
\begin{bmatrix}
\frac{\partial f}{\partial g}
\end{bmatrix}
\begin{bmatrix}
\frac{\partial g}{\partial x_1} &
\frac{\partial g}{\partial x_2}
\end{bmatrix}\\
& =
\begin{bmatrix}
\frac{\partial f}{\partial g}\frac{\partial g}{\partial x_1} &
\frac{\partial f}{\partial g}\frac{\partial g}{\partial x_2}
\end{bmatrix}\\
& =
\begin{bmatrix}
\frac{\partial f}{\partial x_1} &
\frac{\partial f}{\partial x_2}
\end{bmatrix}
\end{align}
```
L'idée de reverse diff c'est d'effectuer le produit de gauche à droite:
```math
\begin{align}
\nabla_{x_1, x_2} f(g(h(x_1, x_2)))
& =
\begin{bmatrix}
\frac{\partial f}{\partial g}\frac{\partial g}{\partial h}
\end{bmatrix}
\begin{bmatrix}
\frac{\partial h}{\partial x_1} &
\frac{\partial h}{\partial x_2}
\end{bmatrix}\\
& =
\begin{bmatrix}
\frac{\partial f}{\partial h}
\end{bmatrix}
\begin{bmatrix}
\frac{\partial h}{\partial x_1} &
\frac{\partial h}{\partial x_2}
\end{bmatrix}\\
& =
\begin{bmatrix}
\frac{\partial f}{\partial x_1} &
\frac{\partial f}{\partial x_2}
\end{bmatrix}
\end{align}
```
"""

# ╔═╡ 4e1ac5fc-c684-42e1-9c99-3120021eb19a
md"""
Pour calculer ``\partial f / \partial x_1`` via forward diff, on part donc de ``\partial x_1 / \partial x_1 = 1`` et ``\partial x_2 / \partial x_1 = 0`` et on calcule ensuite ``\partial h / \partial x_1``, ``\partial g / \partial x_1`` puis ``\partial f / \partial x_1``.
Effectuer la reverse diff est un peu moins intuitif. L'idée est de partir de la dérivée du résultat par rapport à lui même ``\partial f / \partial f = 1`` et de calculer ``\partial f / \partial g`` puis ``\partial f / \partial h`` et ensuite ``\partial f / \partial x_1``. L'avantage de reverse diff c'est qu'il n'y a que la dernière étape qui est sécifique à ``x_1``. Tout jusqu'au calcul de ``\partial f / \partial h`` peut être réutilisé pour calculer ``\partial f / \partial x_2``, il n'y a plus cas multiplier ! Reverse diff est donc plus efficace pour calculer le gradient d'une fonction qui a une seul output par rapport à beaucoup de paramètres comme détaillé dans la discussion à la fin de ce notebook.
"""

# ╔═╡ 56b32132-113f-459f-b1d9-abb8f439a40b
md"""
### Forward pass : Construction de l'expression graph

Pour implémenter reverse diff, il faut construire l'expression graph pour garder en mémoire les valeurs des différentes expressions intermédiaires afin de pouvoir calculer les dérivées locales ``\partial f / \partial g`` et ``\partial g / \partial h``. Le code suivant défini un noeud de l'expression graph. Le field `derivative` correspond à la valeur de ``\partial f_{\text{final}} / \partial f_{\text{node}}`` où ``f_\text{final}`` est la dernière fonction de la composition et ``f_{\text{node}}`` est la fonction correspondant au node.
"""

# ╔═╡ 4931adf1-8771-4708-833e-d05c05884969
begin
	mutable struct Node
		op::Union{Nothing,Symbol}
		args::Vector{Node}
		value::Float64
		derivative::Float64
	end
	Node(op, args, value) = Node(op, args, value, NaN)
	Node(value) = Node(nothing, Node[], value)
end

# ╔═╡ 0b07b9cf-83b4-46e9-9a75-cf2cadbbb011
md"""
L'operateur overloading suivant sera sufficant pour construire l'expression graph dans le cadre de ce notebook, vous l'étendrez pendant la séance d'exercice.
"""

# ╔═╡ b814dc16-37de-45d1-9c7c-4eec45d3f956
begin
	Base.zero(x::Node) = Node(0.0)
	Base.:*(x::Node, y::Node) = Node(:*, [x, y], x.value * y.value)
	Base.:+(x::Node, y::Node) = Node(:+, [x, y], x.value + y.value)
	Base.:-(x::Node, y::Node) = Node(:-, [x, y], x.value - y.value)
	Base.:/(x::Node, y::Number) = x * Node(inv(y))
	Base.:^(x::Node, n::Integer) = Base.power_by_squaring(x, n)
	Base.sin(x::Node) = Node(:sin, [x], sin(x.value))
	Base.cos(x::Node) = Node(:cos, [x], cos(x.value))
end

# ╔═╡ 851e688f-2b30-44b7-9530-87990adee4b2
Base.:*(x::Dual{T}, y::Dual{T}) where {T} = Dual(x.value * y.value, x.value * y.derivative + x.derivative * y.value)

# ╔═╡ 2d469929-da96-4b07-a5a4-defa3d253c81
mse(w, X, y) = sum((X * w - y).^2 / length(y))

# ╔═╡ 15390f36-bc62-4c25-a866-5641aecc86ed
function train!(diff, loss, w0, X, y, η, num_iters)
	w = copy(w0)
	training_losses = [loss(w, X, y)]
	for _ in 1:num_iters
		∇ = diff(loss, w, X, y)
		w .= w .- η .* ∇
		push!(training_losses, loss(w, X, y))
	end
	return w, training_losses
end

# ╔═╡ a767d45f-a438-4d87-bdab-7d55ea7458ac
lift(x) = [1.0, x[1], x[2], x[1]^2, x[1] * x[2], x[2]^2, x[1]^3, x[1]^2 * x[2], x[1] * x[2]^2, x[2]^3]

# ╔═╡ 42644265-8f26-4118-9e8f-537078847af7
function Base.abs(d::Dual)
	if d.value < 0
		return -1.0 * d
	else
		return d
	end
end

# ╔═╡ 607000ef-fb7f-4204-b543-3cb6bb75ed71
let
	x = range(-1, stop = 1, length = 11)
	p = plot(x, abs, axis = :equal, label = "|x|")
	for λ in range(0, stop = 1, length = 11)
		plot!([0, λ/2 - (1 - λ)/2], [0, -1/2], arrow = Plots.arrow(:closed), label = "")
	end
	p
end

# ╔═╡ b899a93f-9bec-48ce-b0ad-4e5157556a31
L1_loss(w, X, y) = sum(abs.(X * w - y)) / length(y)

# ╔═╡ 1572f901-c688-435e-81b9-d6e39bb82201
md"""
On crée les leafs correspondant aux variables ``x_1`` et ``x_2`` de valeur ``1`` et ``2`` respectivement. Les valeurs correspondent aux valeurs de ``x_1`` et ``x_2`` auxquelles on veut dériver la fonction. On a choisi 1 et 2 pour pouvoir les reconnaitre facilement dans le graphe.
"""

# ╔═╡ b7faa3b7-e0b6-4f55-8763-035d8fc5ac93
x_nodes = Node.([1, 2])

# ╔═╡ 194d3a68-6bed-41d9-b3ea-8cfaf4787c54
expr = cos(sin(prod(x_nodes)))

# ╔═╡ 7285c7e8-bce0-42f0-a53b-562a8a6c5894
function _nodes!(nodes,  x::Node)
	if !(x in keys(nodes))
		nodes[x] = length(nodes) + 1
	end
	for arg in x.args
		_nodes!(nodes, arg)
	end
end

# ╔═╡ b9f0e9b6-c111-4d69-990f-02c460c8706d
function _edges(g, labels, nodes::Dict{Node}, done, x::Node)
	id = nodes[x]
	if done[id]
		return
	end
	done[id] = true
	labels[id] = @sprintf "%.2f" x.value
	if !isnothing(x.op)
		labels[id] = "[" * String(x.op) * "] " * labels[id]
	end
	for arg in x.args
		add_edge!(g, id, nodes[arg])
		_edges(g, labels, nodes, done, arg)
	end
end

# ╔═╡ 114c048f-f619-4e15-8e5a-de852b0a1861
function graph(x::Node)
	nodes = Dict{Node,Int}()
	_nodes!(nodes, x)
	done = falses(length(nodes))
	g = DiGraph(length(nodes))
	labels = Vector{String}(undef, length(nodes))
	_edges(g, labels, nodes, done, x)
	return g, labels
end

# ╔═╡ 7578be43-8dbe-4041-adc7-275f06057bfe
md"""
Pour le visualiser, on le converti en graphe utilisant la structure de donnée de Graphs.jl pour pouvoir utiliser `gplot`
"""

# ╔═╡ 69298293-c9fc-432f-9c3c-5da7ce710334
expr_graph, labels = graph(expr)

# ╔═╡ 9b9e5fc3-a8d0-4c42-91ae-25dd01bc7d7e
gplot(expr_graph, nodelabel = labels)

# ╔═╡ 54af5dab-e669-45eb-b6b5-44c46f7258b4
md"""
#### Combinaison des dérivées

Que faire si plusieurs expressions dépendent d'une même variable.
Considérons l'exemple ``f(x) = \sin(x)\cos(x)`` qui correspond à ``f(g,h) = gh``, ``g(x) = \sin(x)`` et ``h(x) = \cos(x)``.
La chain rule donne
```math
\begin{align}
  f'(x) & = \frac{\partial f}{\partial g}g'(x) + \frac{\partial f}{\partial h}h'(x)
\end{align}
```
Une fois la valeur ``\partial f / \partial g`` calculée, on peut la multiplier par ``g'(x)`` pour avoir la première partie partie de ``f'(x)``. Idem pour ``h``. Ces deux contributions seront calculée séparément lors de la backward pass sur le noeud ``g`` et ``h``. On voit par la formule de la chain rule que ces deux contributions doivent être sommées.
Lors de la backward pass, on initialise donc toutes les dérivées à 0. Pour chaque contribution, on ajoute la dérivée avec `+=`. On s'assure ensuite qu'on ne procède pas à la backward pass sur un noeud avant qu'il ait fini d'accumuler les contributions de toutes les expressions qui en dépendent via un *tri topologique*.
"""

# ╔═╡ 842df050-e0be-441d-b84e-7f0575eac227
x_node = Node(1)

# ╔═╡ 36fcfd5e-c521-42fc-96cd-93787e657627
sin_cos = sin(x_node) * cos(x_node)

# ╔═╡ f1da5c61-9862-44f6-84e4-96217736e1cb
sin_cos_graph, sin_cos_labels = graph(sin_cos)

# ╔═╡ 363af09c-3cc9-440d-9b70-1da8f6a70913
gplot(sin_cos_graph, nodelabel = sin_cos_labels)

# ╔═╡ bd705ddd-0d00-41a0-aa55-e82daad4133d
md"### Backward pass : Calcul des dérivées"

# ╔═╡ d8052188-f2fa-4ad8-935f-581eea164bda
md"""
La fonction suivante propage la dérivée ``\partial f_{\text{final}} / \partial f_{\text{node}}`` à la dérivée des arguments de la fonction ``f_{\text{node}}``.
Comme les arguments peuvent être utilisés à par d'autres fonction, on somme la dérivée avec `+=`.
"""

# ╔═╡ 1e08b49d-03fe-4fb3-a8ba-3a00e1374b32
function _backward!(f::Node)
	if isnothing(f.op)
		return
	elseif f.op == :+
		for arg in f.args
			arg.derivative += f.derivative
		end
	elseif f.op == :- && length(f.args) == 2
		f.args[1].derivative += f.derivative
		f.args[2].derivative -= f.derivative
	elseif f.op == :* && length(f.args) == 2
		f.args[1].derivative += f.derivative * f.args[2].value
		f.args[2].derivative += f.derivative * f.args[1].value
	elseif f.op == :sin
		f.args[].derivative += f.derivative * cos(f.args[].value)
	elseif f.op == :cos
		f.args[].derivative -= f.derivative * sin(f.args[].value)
	else
		error("Operator `$(f.op)` not supported yet")
	end
end

# ╔═╡ 44442c34-e088-493a-bfd6-9c095c499100
md"""
La fonction `_backward!` ne doit être appelée que sur un noeud pour lequel `f.derivative` a déjà été calculé. Pour cela, `_backward!` doit avoir été appelé sur tous les noeuds qui représente des fonctions qui dépendent directement ou indirectement du résultat du noeud.
Pour trouver l'ordre dans lequel appeler `_backward!`, on utilise donc on tri topologique (nous reviendrons sur les tris topologique dans la partie graphe).
"""

# ╔═╡ 86872f35-d62d-40e5-8770-4585d3b0c0d7
function topo_sort!(visited, topo, f::Node)
	if !(f in visited)
		push!(visited, f)
		for arg in f.args
			topo_sort!(visited, topo, arg)
		end
		push!(topo, f)
	end
end

# ╔═╡ 26c40cf4-9585-4762-abf4-ff77342a389f
function backward!(f::Node)
	topo = typeof(f)[]
	topo_sort!(Set{typeof(f)}(), topo, f)
	reverse!(topo)
	for node in topo
		node.derivative = 0
	end
	f.derivative = 1
	for node in topo
		_backward!(node)
	end
	return f
end

# ╔═╡ 86fc7924-2002-4ac6-8e02-d9bf5edde9bf
backward!(expr)

# ╔═╡ d72d9c99-6280-49a2-9f7a-e9628f1069eb
md"On a maintenant l'information sur les dérivées de `x_nodes`:"

# ╔═╡ 0649437a-4198-4556-97dc-1b5cfbe45eed
x_nodes

# ╔═╡ 3928e9f7-9539-4d99-ac5b-6336eff8a523
md"""
### Comparaison avec Forward Diff dans l'exemple moon

Revenons sur l'exemple utilisé pour illustrer la forward diff et essayons de calculer la même dérivée mais à présent en utiliser reverse diff.
"""

# ╔═╡ 5ce7fbad-af38-4ff6-adca-b1991f3be455
w_nodes = Node.(w)

# ╔═╡ 0dd8e1bf-f8c0-4183-a5eb-13eeb5316a7b
mse_expr = backward!(mse(Node.(ones(1)), Node.(2ones(1, 1)), Node.(3ones(1))))

# ╔═╡ 7a320b75-c104-43d1-9129-f7f53910f5bc
function reverse_diff(loss, w, X, y)
	w_nodes = Node.(w)
	expr = loss(w_nodes, Node.(X), Node.(y))
	backward!(expr)
	return [w.derivative for w in w_nodes]
end

# ╔═╡ a610dc3c-803a-4489-a84b-8bff415bc0a6
md"We execute it a second time to get rid of the compilation time:"

# ╔═╡ 0e99048d-5696-43ab-8896-301f37a20a5d
md"On remarque que reverse diff est plus lent! IL y a un certain coût mémoire lorsqu'on consruit l'expression graph. Pour cette raison, si on veut calculer plusieurs dérivées consécutives pour différentes valeurs de ``x_1`` et ``x_2``, on a intérêt à garder le graphe et à uniquement changer la valeur des variables plutôt qu'à reconstruire le graphe à chaque fois qu'on change les valeurs. Alternativement, on peut essayer de condenser le graphe en exprimant les opérations sur des large matrices ou même tenseurs, c'est l'approche utilisée par pytorch ou tensorflow."

# ╔═╡ bd012d84-a79f-4043-961e-f7825b7e0d6c
md"`num_data` = $(@bind(num_data, Slider(1:100, default = 32, show_value = true)))"

# ╔═╡ 03f6d241-712d-4a45-b926-09be326c1c7d
md"`num_features` = $(@bind(num_features, Slider(1:100, default = 32, show_value = true)))"

# ╔═╡ e9507958-cefd-4208-896e-860d3e4e9d4b
md"`num_hidden` = $(@bind(num_hidden, Slider(1:100, default = 32, show_value = true)))"

# ╔═╡ 8acebedb-3a97-4efd-bd3c-c267ecd3945c
mse2(W1, W2, X, y) = sum((X * W1 * W2 - y).^2 / length(y))

# ╔═╡ 32fdcdd9-785d-427b-94c3-3c65bf72e673
function bench(num_data, num_features, num_hidden)
	X = rand(num_data, num_features)
	W1 = rand(num_features, num_hidden)
	W2 = rand(num_hidden)
	y = rand(num_data)
	
	@time for i in axes(W1, 1)
		for j in axes(W1, 2)
			mse2(
			    Dual.(W1, onehot(i, axes(W1, 1)) * onehot(j, axes(W1, 2))'),
				W2,
				X,
				y,
			)
		end
	end
	expr = @time mse2(Node.(W1), Node.(W2), Node.(X), Node.(y))
	@time backward!(expr)
	return
end

# ╔═╡ 8ce88d4d-59b0-49bb-8c0a-3a2961e5fd4a
bench(num_data, num_features, num_hidden)

# ╔═╡ 613269ef-16ba-44ef-ad8e-997cc9aec1fb
md"""
### Comment choisir entre forward et reverse diff ?

Suppose that we need to differentiate a composition of functions:
``(f_n \circ f_{n-1} \circ \cdots \circ f_2 \circ f_1)(w)``.
For each function, we can compute a jacobian given the value of its input.
So, during a forward pass, we can compute all jacobians. We now just need to take the product of these jacobians:
```math
J_n J_{n-1} \cdots J_2 J_1
```
While the product of matrices is associative, its computational complexity depends on the order of the multiplications!
Let ``d_i \times d_{i - 1}`` be the dimension of ``J_i``.

#### Forward diff: from right to left

If the product is computed from right to left:
```math
\begin{align}
  J_{1,2} & = J_2 J_1 && \Omega(d_2d_1d_0)\\
  J_{1,3} & = J_3 J_{1,2} && \Omega(d_3d_2d_0)\\
  J_{1,4} & = J_4 J_{1,3} && \Omega(d_4d_3d_0)\\
  \vdots & \quad \vdots\\
  J_{1,n} & = J_n J_{1,(n-1)} && \Omega(d_nd_{n-1}d_0)
\end{align}
```
we have a complexity of
```math
\Omega(\sum_{i=2}^n d_id_{i-1}d_0).
```

#### Reverse diff: from left to right

Reverse differentation corresponds to multiplying the adjoint from right to left or equivalently the original matrices from left to right.
This means computing the product in the following order:
```math
\begin{align}
  J_{(n-1),n} & = J_n J_{n-1} && \Omega(d_nd_{n-1}d_{n-2})\\
  J_{(n-2),n} & = J_{(n-1),n} J_{n-2} && \Omega(d_nd_{n-2}d_{n-3})\\
  J_{(n-3),n} & = J_{(n-2),n} J_{n-3} && \Omega(d_nd_{n-3}d_{n-4})\\
  \vdots & \quad \vdots\\
  J_{1,n} & = J_{2,n} J_1 && \Omega(d_nd_1d_0)\\
\end{align}
```
We have a complexity of
```math
\Omega(\sum_{i=1}^{n-1} d_nd_id_{i-1}).
```

#### Mixed : from inward to outward

Suppose we multiply starting from some ``d_k`` where ``1 < k < n``.
We would then first compute the left side:
```math
\begin{align}
  J_{k+1,k+2} & = J_{k+2} J_{k+1} && \Omega(d_{k+2}d_{k+1}d_{k})\\
  J_{k+1,k+3} & = J_{k+3} J_{k+1,k+2} && \Omega(d_{k+3}d_{k+2}d_{k})\\
  \vdots & \quad \vdots\\
  J_{k+1,n} & = J_{n} J_{k+1,n-1} && \Omega(d_nd_{n-1}d_k)
\end{align}
```
then the right side:
```math
\begin{align}
  J_{k-1,k} & = J_k J_{k-1} && \Omega(d_kd_{k-1}d_{k-2})\\
  J_{k-2,k} & = J_{k-1,k} J_{k-2} && \Omega(d_kd_{k-2}d_{k-3})\\
  \vdots & \quad \vdots\\
  J_{1,k} & = J_{2,k} J_1 && \Omega(d_kd_1d_0)\\
\end{align}
```
and then combine both sides:
```math
J_{1,n} = J_{k+1,n} J_{1,k} \qquad \Omega(d_nd_kd_0)
```
we have a complexity of
```math
\Omega(d_nd_kd_0 + \sum_{i=1}^{k-1} d_kd_id_{i-1} + \sum_{i=k}^{n} d_id_{i-1}d_k).
```

#### Comparison

We see that we should find the minimum ``d_k`` and start from there. If the minimum is attained at ``k = n``, this corresponds mutliplying from left to right, this is reverse differentiation. If the minimum is attained at ``k = 0``, we should multiply from right to left, this is forward differentiation. Otherwise, we should start from the middle, this would mean mixing both forward and reverse diff.

What about neural networks ? In that case, ``d_0`` is equal to the number of entries in ``W_1`` added with the number of entries in ``W_2`` while ``d_n`` is ``1`` since the loss is scalar. We should therefore clearly multiply from left to right hence do reverse diff.
"""

# ╔═╡ fdd28672-5902-474a-8c87-3f6f38bcf54f
md"""
## Pour la séance d'exercices:
"""

# ╔═╡ 54697e82-ee8c-4b65-a633-b29a47fac722
md"### tanh

Passer un réseau de neurone avec fonction d'activation `tanh`
"

# ╔═╡ b5286a91-597d-4b66-86b2-1528708dfa93
W2 = rand(num_hidden)

# ╔═╡ 24b95ecb-0df7-4af2-9d7e-c76ce380c6a6
md"### ReLU

Passer un réseau de neurone avec fonction d'activation ReLU"

# ╔═╡ 21b97f3d-85c8-420b-a884-df4fed98b8d0
function relu(x)
	if x < 0
		return 0
	else
		return x
	end
end

# ╔═╡ 73cbbbd0-8427-46d3-896b-7cfc732c35f7
md"""
### One-Hot encoding et cross-entropy
"""

# ╔═╡ c1da4130-5936-499f-bb9b-574e01136eca
md"### Acknowledgements and further readings

* `Dual` est inspiré de [ForwardDiff](https://github.com/JuliaDiff/ForwardDiff.jl)
* `Node` est inspiré de [micrograd](https://github.com/karpathy/micrograd)
* Une bonne intro à l'automatic differentiation est disponible [ici](https://gdalle.github.io/AutodiffTutorial/)
"

# ╔═╡ b16f6225-1949-4b6d-a4b0-c5c230eb4c7f
md"## Utils"

# ╔═╡ dad5cba4-9bc6-47c3-a932-f2cc496b0f40
import MLJBase, Colors, Tables

# ╔═╡ 0a6b0db0-03f7-4077-b330-5f27f7c7a9a2
X_table, y_cat = MLJBase.make_moons(100, noise=0.1)

# ╔═╡ 7535debf-13ff-4bef-92fb-cdbf7fef7515
y = 2(float.(y_cat.refs) .- 1.5)

# ╔═╡ f90fd2b4-7aec-40f5-85b7-00674582a902
Y = unique!(sort(y_cat.refs))' .== y_cat.refs

# ╔═╡ d893fb13-fadb-452c-ba93-96f630bab3cd
function plot_w(w = nothing)
	col = [Colors.JULIA_LOGO_COLORS.red, Colors.JULIA_LOGO_COLORS.blue]
	p = scatter(X_table.x1, X_table.x2, markerstrokewidth=0, color = col[y_cat.refs], label = "")
	if isnothing(w)
		return p
	elseif length(w) == 2
		plot!([extrema(X_table.x1)...], x1 -> -w[1] * x1 / w[2], label = "", color = Colors.JULIA_LOGO_COLORS.green, linewidth = 2)
	else
		x1 = range(minimum(X_table.x1), stop = maximum(X_table.x1), length = 30)
		x2 = range(minimum(X_table.x2), stop = maximum(X_table.x2), length = 30)
		contour!(x1, x2, (x1, x2) -> w' * lift([x1, x2]), label = "", colorbar_ticks=([1], [0.0]))
	end
end

# ╔═╡ 36401e91-1121-4552-bc4e-1b1aac76d1e0
plot_w()

# ╔═╡ 054a167c-1d5c-4c8a-9977-22b4e4d5f05d
plot_w(w)

# ╔═╡ 28349f82-f2e7-46ea-82b5-306e9dbb6daa
X = Tables.matrix(X_table)

# ╔═╡ 76c147ac-73c1-421f-9c9d-681a91e02b91
y_est = X * w

# ╔═╡ 03bc2513-e542-4ac8-8edc-8fdf3793b834
errors = y_est - y

# ╔═╡ 0af91567-90ae-47d2-9d5a-9f33b623a204
mean_squared_error = sum(errors.^2) / length(errors)

# ╔═╡ 96e35052-8697-495c-8ded-5f6348b7e711
mse(w, X, y)

# ╔═╡ 2904c070-d595-4cff-a507-f360f1e774dd
mse(Dual.(w, onehot(1, 1:2)), X, y)

# ╔═╡ d0bc2ab9-9c9f-4c60-bfa7-cbcdffc20ba6
forward_diff(mse, w, X, y, 1)

# ╔═╡ be3404c5-a2b6-4df9-ae31-d5a8b6ec1c92
∇ = forward_diff(mse, w, X, y)

# ╔═╡ 06870328-9a78-4b5f-a405-7654af38035b
losses = [mse(w + η * ∇, X, y) for η in step_sizes]

# ╔═╡ 604cdb54-6060-46a1-b4cb-22fb58394720
best_idx = argmin(losses)

# ╔═╡ 1ad80bdb-84d3-418d-8bda-c3decbe08ae0
η_best = step_sizes[best_idx]

# ╔═╡ b85211fa-bcf4-4b4e-b028-b49361a92c2c
w_improved = w + η_best * ∇

# ╔═╡ 57a78422-066b-4cda-a902-b4b34af375e6
best_loss = losses[best_idx]

# ╔═╡ 92250d6f-3a95-475e-8532-c98e3bea63e2
begin
	plot(step_sizes, losses, label = "")
	scatter!([0.0], [mse(w, X, y)], markerstrokewidth = 0, label = "")
	scatter!([η_best], [best_loss], markerstrokewidth = 0, label = "")
end

# ╔═╡ 33654f91-0b61-4b39-b0fb-ef21776f0dfc
w_trained, training_losses = train!(forward_diff, mse, w, X, y, 0.7, num_iters)

# ╔═╡ 56558e41-e3ae-42e5-8695-3d2077cbc10c
plot(0:num_iters, training_losses, label = "")

# ╔═╡ c1059a32-8d65-4957-989f-2c5b5f50eb81
plot_w(w_trained)

# ╔═╡ 403f2e6c-5dec-4206-a5c0-d4a90fafc029
X_lift = reduce(vcat, transpose.(lift.(eachrow(X))))

# ╔═╡ f56a567b-62db-43b6-8dce-db9d5ca1e348
w_lift = rand(size(X_lift, 2))

# ╔═╡ b4b31659-8dc9-4837-8a6f-8d40b41b2366
plot_w(w_lift)

# ╔═╡ d69b0cfe-ce30-420d-a891-c6e35e11cdde
w_lift_trained, training_losses_lift = train!(forward_diff, mse, w_lift, X_lift, y, η_lift, num_iters_lift)

# ╔═╡ c1e29f52-424b-4cb2-814e-b4aecda86bc6
plot(0:num_iters_lift, training_losses_lift, label = "")

# ╔═╡ 7606f18e-9833-48cd-8c21-b48be30ef6f8
plot_w(w_lift_trained)

# ╔═╡ 91e5840a-8a18-4d36-8fce-510af4c7dcf2
w_trained_L1, training_losses_L1 = train!(forward_diff, L1_loss, w_lift, X_lift, y, η_L1, num_iters_L1)

# ╔═╡ 4a807c44-f33e-4a58-99b3-261c392be891
plot(0:num_iters_L1, training_losses_L1, label = "")

# ╔═╡ b5f3c2b1-c86a-48e4-973b-ee639d784936
plot_w(w_trained_L1)

# ╔═╡ c1b73208-f917-4823-bf45-d896f4ee59e0
@time forward_diff(mse, w, X, y)

# ╔═╡ 4444622b-ccfe-4867-b659-489573099f1e
@time reverse_diff(mse, w, X, y)

# ╔═╡ c1942ee2-c5af-4b2b-986d-6ad563ef27bb
@time reverse_diff(mse, w, X, y)

# ╔═╡ 0af6bce6-bc3b-438e-a57b-0c0c6586c0c5
W1 = rand(size(X, 2), num_hidden)

# ╔═╡ c3442bea-4ba9-4711-8d70-0ddd1745dd58
y_est_tanh = tanh.(X * W1) * W2

# ╔═╡ 83180cd9-21b1-4e70-8d54-4bf03efa31be
y_est_relu = relu.(X * W1) * W2

# ╔═╡ a05e3426-f014-473c-aad1-1cc6351a8911
W = rand(size(X, 2), size(Y, 2))

# ╔═╡ ba09be29-2af6-432e-871b-0637c52c68cf
Y_1 = X * W

# ╔═╡ 7a4156bd-5316-43ca-9cdc-d7e39f3c152f
Y_2 = exp.(X * W)

# ╔═╡ 82ab5eed-eefe-4421-9a1e-7c3b0eea0523
sums = sum(Y_2, dims=2)

# ╔═╡ e16e9464-0a27-49ef-9b17-5ea850d253b4
Y_est = Y_2 ./ sums

# ╔═╡ f761b97e-f1cb-406a-b0e9-75e4ec665097
cross = Y_est .* Y

# ╔═╡ f714edaa-ba9a-46eb-89f0-5bcc4120015e
cross_entropies = -log.(sum(Y_est .* Y, dims=2))

# ╔═╡ 1b7f3578-1de5-498c-b70f-9b4aa20d2edd
-log.(getindex.(Ref(Y_est), axes(Y_est, 1), y_cat.refs))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
GraphPlot = "a2cc645c-3eea-5389-862e-a155d0052231"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
MLJBase = "a7f614a8-145f-11e9-1d2a-a57a1082229d"
OneHotArrays = "0b1bfda6-eb8a-41d2-88d8-f5af5cad476f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[compat]
Colors = "~0.12.11"
GraphPlot = "~0.6.0"
Graphs = "~1.9.0"
MLJBase = "~1.7.0"
OneHotArrays = "~0.2.5"
Plots = "~1.40.8"
PlutoUI = "~0.7.60"
Tables = "~1.12.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.1"
manifest_format = "2.0"
project_hash = "647c126887a2ffbf11df74e3cf03bb0463ccc843"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "InverseFunctions", "LinearAlgebra", "MacroTools", "Markdown"]
git-tree-sha1 = "b392ede862e506d451fc1616e79aa6f4c673dab8"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.38"

    [deps.Accessors.extensions]
    AccessorsAxisKeysExt = "AxisKeys"
    AccessorsDatesExt = "Dates"
    AccessorsIntervalSetsExt = "IntervalSets"
    AccessorsStaticArraysExt = "StaticArrays"
    AccessorsStructArraysExt = "StructArrays"
    AccessorsTestExt = "Test"
    AccessorsUnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    Requires = "ae029012-a4dd-5104-9daa-d747884805df"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "6a55b747d1812e699320963ffde36f1ebdda4099"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.4"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Atomix]]
deps = ["UnsafeAtomics"]
git-tree-sha1 = "c06a868224ecba914baa6942988e2f2aade419be"
uuid = "a9b6321e-bd34-4604-b9c9-b65b8de01458"
version = "0.1.0"

[[deps.BangBang]]
deps = ["Accessors", "ConstructionBase", "InitialValues", "LinearAlgebra", "Requires"]
git-tree-sha1 = "e2144b631226d9eeab2d746ca8880b7ccff504ae"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.4.3"

    [deps.BangBang.extensions]
    BangBangChainRulesCoreExt = "ChainRulesCore"
    BangBangDataFramesExt = "DataFrames"
    BangBangStaticArraysExt = "StaticArrays"
    BangBangStructArraysExt = "StructArrays"
    BangBangTablesExt = "Tables"
    BangBangTypedTablesExt = "TypedTables"

    [deps.BangBang.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
    TypedTables = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "8873e196c2eb87962a2048b3b8e08946535864a1"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+2"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "1568b28f91293458345dabba6a5ea3f183250a61"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.8"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.CategoricalDistributions]]
deps = ["CategoricalArrays", "Distributions", "Missings", "OrderedCollections", "Random", "ScientificTypes"]
git-tree-sha1 = "926862f549a82d6c3a7145bc7f1adff2a91a39f0"
uuid = "af321ab8-2d2e-40a6-b165-3d674595d28e"
version = "0.1.15"

    [deps.CategoricalDistributions.extensions]
    UnivariateFiniteDisplayExt = "UnicodePlots"

    [deps.CategoricalDistributions.weakdeps]
    UnicodePlots = "b8865327-cd53-5732-bb35-84acbb429228"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "3e4b134270b372f2ed4d4d0e936aabaefc1802bc"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b5278586822443594ff615963b0c09755771b3e0"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.26.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

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

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "bf6570a34c850f99407b494757f5d7ad233a7257"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.5"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "ea32b83ca4fefa1768dc84e504cc0a94fb1ab8d1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.2"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ContextVariablesX]]
deps = ["Compat", "Logging", "UUIDs"]
git-tree-sha1 = "25cc3803f1030ab855e383129dcd3dc294e322cc"
uuid = "6add18c4-b38d-439d-96f6-d6bc489c04c5"
version = "0.1.3"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

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

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "d7477ecdafb813ddee2ae727afa94e9dcb5f3fb0"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.112"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c6317308b9dc757616f0b5cb379db10494443a7"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.2+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FLoops]]
deps = ["BangBang", "Compat", "FLoopsBase", "InitialValues", "JuliaVariables", "MLStyle", "Serialization", "Setfield", "Transducers"]
git-tree-sha1 = "0a2e5873e9a5f54abb06418d57a8df689336a660"
uuid = "cc61a311-1640-44b5-9fba-1b764f453329"
version = "0.2.2"

[[deps.FLoopsBase]]
deps = ["ContextVariablesX"]
git-tree-sha1 = "656f7a6859be8673bf1f35da5670246b923964f7"
uuid = "b9860ae5-e623-471e-878b-f6a53c775ea6"
version = "0.1.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "db16beca600632c95fc8aca29890d83788dd8b23"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.96+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "5c1d8ae0efc6c2e7b1fc502cbe25def8f661b7bc"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.2+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1ed150b39aebcc805c26b93a8d0122c940f64ce2"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.14+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "532f9126ad901533af1d4f5c198867227a7bb077"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+1"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "ec632f177c0d990e64d955ccc1b8c04c485a0950"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.6"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "ee28ddcd5517d54e417182fec3886e7412d3926f"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.8"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f31929b9e67066bee48eec8b03c0df47d31a74b3"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.8+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "674ff0db93fffcd11a3573986e550d66cd4fd71f"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.80.5+0"

[[deps.GraphPlot]]
deps = ["ArnoldiMethod", "Colors", "Compose", "DelimitedFiles", "Graphs", "LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "f76a7a0f10af6ce7f227b7a921bfe351f628ed45"
uuid = "a2cc645c-3eea-5389-862e-a155d0052231"
version = "0.6.0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "899050ace26649433ef1af25bc17a815b3db52b7"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.9.0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "d1d712be3164d61d1fb98e7ce9bcbc6cc06b45ed"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.8"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "401e4f3f30f43af2c8478fc008da50096ea5240f"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.3.1+0"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "7c4195be1649ae622304031ed46a2f4df989f1eb"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.24"

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

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "39d64b09147620f5ffbf6b2d3255be3c901bec63"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.8"

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

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "25ee0be4d43d0269027024d75a24c24d6c6e590c"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.4+0"

[[deps.JuliaVariables]]
deps = ["MLStyle", "NameResolution"]
git-tree-sha1 = "49fb3cb53362ddadb4415e9b73926d6b40709e70"
uuid = "b14d175d-62b4-44ba-8fb7-3064adc8c3ec"
version = "0.2.4"

[[deps.KernelAbstractions]]
deps = ["Adapt", "Atomix", "InteractiveUtils", "MacroTools", "PrecompileTools", "Requires", "StaticArrays", "UUIDs", "UnsafeAtomics", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "04e52f596d0871fa3890170fa79cb15e481e4cd8"
uuid = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
version = "0.9.28"

    [deps.KernelAbstractions.extensions]
    EnzymeExt = "EnzymeCore"
    LinearAlgebraExt = "LinearAlgebra"
    SparseArraysExt = "SparseArrays"

    [deps.KernelAbstractions.weakdeps]
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "36bdbc52f13a7d1dcb0f3cd694e01677a515655b"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.0+0"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Preferences", "Printf", "Requires", "Unicode"]
git-tree-sha1 = "4ad43cb0a4bb5e5b1506e1d1f48646d7e0c80363"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "9.1.2"

    [deps.LLVM.extensions]
    BFloat16sExt = "BFloat16s"

    [deps.LLVM.weakdeps]
    BFloat16s = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "05a8bd5a42309a9ec82f700876903abce1017dd3"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.34+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "854a9c268c43b77b0a27f22d7fab8d33cdb3a731"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.2+1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"
version = "1.11.0"

[[deps.LearnAPI]]
deps = ["InteractiveUtils", "Statistics"]
git-tree-sha1 = "ec695822c1faaaa64cee32d0b21505e1977b4809"
uuid = "92ad9a40-7767-427a-9ee6-6e577f1266cb"
version = "0.1.0"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "9fd170c4bbfd8b935fdc5f8b7aa33532c991a673"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.11+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fbb1f2bef882392312feb1ede3615ddc1e9b99ed"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.49.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0c4f9c4f1a50d8f35048fa0532dabbadf702f81e"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.1+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "b404131d06f7886402758c9ce2214b636eb4d54a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5ee6203157c120d79034c748a2acba45b82b8807"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.1+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MLJBase]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Dates", "DelimitedFiles", "Distributed", "Distributions", "InteractiveUtils", "InvertedIndices", "LearnAPI", "LinearAlgebra", "MLJModelInterface", "Missings", "OrderedCollections", "Parameters", "PrettyTables", "ProgressMeter", "Random", "RecipesBase", "Reexport", "ScientificTypes", "Serialization", "StatisticalMeasuresBase", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "6f45e12073bc2f2e73ed0473391db38c31e879c9"
uuid = "a7f614a8-145f-11e9-1d2a-a57a1082229d"
version = "1.7.0"

    [deps.MLJBase.extensions]
    DefaultMeasuresExt = "StatisticalMeasures"

    [deps.MLJBase.weakdeps]
    StatisticalMeasures = "a19d573c-0a75-4610-95b3-7071388c7541"

[[deps.MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "ceaff6618408d0e412619321ae43b33b40c1a733"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.11.0"

[[deps.MLStyle]]
git-tree-sha1 = "bc38dff0548128765760c79eb7388a4b37fae2c8"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.17"

[[deps.MLUtils]]
deps = ["ChainRulesCore", "Compat", "DataAPI", "DelimitedFiles", "FLoops", "NNlib", "Random", "ShowCases", "SimpleTraits", "Statistics", "StatsBase", "Tables", "Transducers"]
git-tree-sha1 = "b45738c2e3d0d402dffa32b2c1654759a2ac35a4"
uuid = "f1d291b0-491e-4a28-83b9-f70985020b54"
version = "0.4.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.MicroCollections]]
deps = ["Accessors", "BangBang", "InitialValues"]
git-tree-sha1 = "44d32db644e84c75dab479f1bc15ee76a1a3618f"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.2.0"

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

[[deps.NNlib]]
deps = ["Adapt", "Atomix", "ChainRulesCore", "GPUArraysCore", "KernelAbstractions", "LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "da09a1e112fd75f9af2a5229323f01b56ec96a4c"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.9.24"

    [deps.NNlib.extensions]
    NNlibAMDGPUExt = "AMDGPU"
    NNlibCUDACUDNNExt = ["CUDA", "cuDNN"]
    NNlibCUDAExt = "CUDA"
    NNlibEnzymeCoreExt = "EnzymeCore"
    NNlibFFTWExt = "FFTW"
    NNlibForwardDiffExt = "ForwardDiff"

    [deps.NNlib.weakdeps]
    AMDGPU = "21141c5a-9bdb-4563-92ae-f87d6854732e"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    FFTW = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    cuDNN = "02a925ec-e4fe-4b08-9a7e-0d78e3d38ccd"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NameResolution]]
deps = ["PrettyPrint"]
git-tree-sha1 = "1a0fa0e9613f46c9b8c11eee38ebb4f590013c5e"
uuid = "71a1bf82-56d0-4bbc-8a3c-48b961074391"
version = "0.1.5"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OneHotArrays]]
deps = ["Adapt", "ChainRulesCore", "Compat", "GPUArraysCore", "LinearAlgebra", "NNlib"]
git-tree-sha1 = "963a3f28a2e65bb87a68033ea4a616002406037d"
uuid = "0b1bfda6-eb8a-41d2-88d8-f5af5cad476f"
version = "0.2.5"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7493f61f55a6cce7325f197443aa80d32554ba10"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+1"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e127b609fb9ecba6f201ba7ab753d5a605d53801"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.54.1+0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "6e55c6841ce3411ccb3457ee52fc48cb698d6fb0"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.2.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "650a022b2ce86c7dcfbdecf00f78afeeb20e5655"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.2"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "45470145863035bb124ca51b320ed35d071cc6c2"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.8"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

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

[[deps.PrettyPrint]]
git-tree-sha1 = "632eb4abab3449ab30c5e1afaa874f0b98b586e4"
uuid = "8162dcfd-2161-5ef2-ae6c-7681170c5f98"
version = "0.2.0"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "1101cd475833706e4d0e7b122218257178f48f34"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "8f6bc219586aef8baf0ff9a5fe16ee9c70cb65e4"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.2"

[[deps.PtrArrays]]
git-tree-sha1 = "77a42d78b6a92df47ab37e177b2deac405e1c88f"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.2.1"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "492601870742dcd38f233b23c3ec629628c1d724"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.7.1+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "e5dd466bf2569fe08c91a2cc29c1003f4797ac3b"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.7.1+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "1a180aeced866700d4bebc3120ea1451201f16bc"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.7.1+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "729927532d48cf79f49070341e1d918a65aba6b0"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.7.1+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "cda3b045cf9ef07a08ad46731f5a3165e56cf3da"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.1"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.ScientificTypes]]
deps = ["CategoricalArrays", "ColorTypes", "Dates", "Distributions", "PrettyTables", "Reexport", "ScientificTypesBase", "StatisticalTraits", "Tables"]
git-tree-sha1 = "75ccd10ca65b939dab03b812994e571bf1e3e1da"
uuid = "321657f4-b219-11e9-178b-2701a2544e81"
version = "3.0.2"

[[deps.ScientificTypesBase]]
git-tree-sha1 = "a8e18eb383b5ecf1b5e6fc237eb39255044fd92b"
uuid = "30f210dd-8aff-4c5f-94ba-8e64358c1161"
version = "3.0.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.ShowCases]]
git-tree-sha1 = "7f534ad62ab2bd48591bdeac81994ea8c445e4a5"
uuid = "605ecd9f-84a6-4c9e-81e2-4798472b76a3"
version = "0.1.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "2f5d4697f21388cbe1ff299430dd169ef97d7e14"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.4.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "eeafab08ae20c62c44c8399ccb9354a04b80db50"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.7"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.StatisticalMeasuresBase]]
deps = ["CategoricalArrays", "InteractiveUtils", "MLUtils", "MacroTools", "OrderedCollections", "PrecompileTools", "ScientificTypesBase", "Statistics"]
git-tree-sha1 = "17dfb22e2e4ccc9cd59b487dce52883e0151b4d3"
uuid = "c062fc1d-0d66-479b-b6ac-8b44719de4cc"
version = "0.1.1"

[[deps.StatisticalTraits]]
deps = ["ScientificTypesBase"]
git-tree-sha1 = "542d979f6e756f13f862aa00b224f04f9e445f11"
uuid = "64bff920-2084-43da-a3e6-9bb72801c0c9"
version = "3.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"
weakdeps = ["ChainRulesCore", "InverseFunctions"]

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a6b1675a536c5ad1a60e5a5153e1fee12eb146e3"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.0"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

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

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Transducers]]
deps = ["Accessors", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "ConstructionBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "SplittablesBase", "Tables"]
git-tree-sha1 = "7deeab4ff96b85c5f72c824cae53a1398da3d1cb"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.84"

    [deps.Transducers.extensions]
    TransducersAdaptExt = "Adapt"
    TransducersBlockArraysExt = "BlockArrays"
    TransducersDataFramesExt = "DataFrames"
    TransducersLazyArraysExt = "LazyArrays"
    TransducersOnlineStatsBaseExt = "OnlineStatsBase"
    TransducersReferenceablesExt = "Referenceables"

    [deps.Transducers.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    BlockArrays = "8e7c35d0-a365-5155-bbbb-fb81a777f24e"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    LazyArrays = "5078a376-72f3-5289-bfd5-ec5146d43c02"
    OnlineStatsBase = "925886fa-5bf2-5e8e-b522-a9147a512338"
    Referenceables = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"

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

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "d95fe458f26209c66a187b1114df96fd70839efd"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.21.0"
weakdeps = ["ConstructionBase", "InverseFunctions"]

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.UnsafeAtomics]]
git-tree-sha1 = "6331ac3440856ea1988316b46045303bef658278"
uuid = "013be700-e6cd-48c3-b4a1-df204f14c38f"
version = "0.2.1"

[[deps.UnsafeAtomicsLLVM]]
deps = ["LLVM", "UnsafeAtomics"]
git-tree-sha1 = "2d17fabcd17e67d7625ce9c531fb9f40b7c42ce4"
uuid = "d80eeb9a-aca5-4d75-85e5-170c8b632249"
version = "0.2.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "93f43ab61b16ddfb2fd3bb13b3ce241cafb0e6c9"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.31.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "1165b0443d0eca63ac1e32b8c0eb69ed2f4f8127"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "a54ee957f4c86b526460a720dbc882fa5edcbefc"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.41+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ac88fb95ae6447c8dda6a5503f3bafd496ae8632"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.4.6+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "326b4fea307b0b39892b3e85fa451692eda8d46c"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.1+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "3796722887072218eabafb494a13c963209754ce"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d2d1a5c49fae4ba39983f63de6afcbea47194e85"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "47e45cd78224c53109495b3e324df0c37bb61fbe"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+0"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "bcd466676fef0878338c61e655629fa7bbc69d8e"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "555d1076590a6cc2fdee2ef1469451f872d8b41b"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.6+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "936081b536ae4aa65415d869287d43ef3cb576b2"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.53.0+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1827acba325fdcdf1d2647fc8d5301dd9ba43a9d"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.9.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "b70c870239dc3d7bc094eb2d6be9b73d27bef280"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.44+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╟─77a7de14-87d2-11ef-21ef-937b8239db5b
# ╠═0a6b0db0-03f7-4077-b330-5f27f7c7a9a2
# ╟─d893fb13-fadb-452c-ba93-96f630bab3cd
# ╠═36401e91-1121-4552-bc4e-1b1aac76d1e0
# ╟─677a40de-ef6d-4a41-84f6-05ef6580aeba
# ╠═28349f82-f2e7-46ea-82b5-306e9dbb6daa
# ╟─0325e4a5-f50d-4064-b558-9f6275d4cd5a
# ╠═7535debf-13ff-4bef-92fb-cdbf7fef7515
# ╟─860acc4a-f9ee-49c1-a6d1-d81a3c51d9a8
# ╠═55a0a91d-ebe4-4d8a-a094-b6e0aeec4587
# ╠═054a167c-1d5c-4c8a-9977-22b4e4d5f05d
# ╟─c5b0cb9c-40be-44f6-9173-5a0631ab8834
# ╠═76c147ac-73c1-421f-9c9d-681a91e02b91
# ╟─b4d2b635-bbb3-4024-877b-a96fdd19349e
# ╠═03bc2513-e542-4ac8-8edc-8fdf3793b834
# ╟─af404768-0663-4bc3-81dd-6931b3a486be
# ╠═0af91567-90ae-47d2-9d5a-9f33b623a204
# ╠═2d469929-da96-4b07-a5a4-defa3d253c81
# ╠═96e35052-8697-495c-8ded-5f6348b7e711
# ╟─277bd2ce-fa7f-4288-be8a-0ddd8f23635c
# ╠═94f2f9ef-9467-4781-9dfb-f0a32141f542
# ╟─e001e562-901f-4afa-a5ad-9bbecdae1694
# ╠═ea2a923b-df68-4cb8-a3ff-62b0aadcc4f2
# ╟─e8d8219d-1119-4f81-bc85-b27e33383fff
# ╠═82ccdf44-5c45-4d55-ac1d-f4ec0a146b29
# ╟─80356507-0b92-4c62-8bdf-865e345a29dc
# ╠═851e688f-2b30-44b7-9530-87990adee4b2
# ╟─c0caef28-d59a-43a1-af4f-6756c3b41903
# ╠═a2ac721c-700e-4bbf-8c13-3b06db292c00
# ╠═3f7cfa28-b060-4a3e-b61a-fd42be8e6939
# ╠═7d805d6a-9077-4d97-a0db-c1bd306cbbb8
# ╠═7dfc8a90-5a7d-4457-b382-f9552e02fd73
# ╠═42eacb3a-54b0-43e8-97a1-07a71ac3faf5
# ╠═2904c070-d595-4cff-a507-f360f1e774dd
# ╠═42f15c09-49f7-40e0-8892-0ade61a3c923
# ╠═d0bc2ab9-9c9f-4c60-bfa7-cbcdffc20ba6
# ╠═4dde16bc-2c40-4214-8963-2d7a7287f587
# ╟─b7303267-3404-4542-a7f8-5960859abc19
# ╟─b025aa9e-1137-4201-b7b8-2b803f8aa17e
# ╠═be3404c5-a2b6-4df9-ae31-d5a8b6ec1c92
# ╟─0b4d8741-e9fb-40e4-a8be-cf21683b8f79
# ╠═7ad77ed6-de39-430e-9e71-1c3d37ce7f34
# ╠═06870328-9a78-4b5f-a405-7654af38035b
# ╠═604cdb54-6060-46a1-b4cb-22fb58394720
# ╠═1ad80bdb-84d3-418d-8bda-c3decbe08ae0
# ╠═57a78422-066b-4cda-a902-b4b34af375e6
# ╟─53fe00ff-32d1-4c61-ae89-e54df5efc3a0
# ╠═92250d6f-3a95-475e-8532-c98e3bea63e2
# ╠═b85211fa-bcf4-4b4e-b028-b49361a92c2c
# ╠═15390f36-bc62-4c25-a866-5641aecc86ed
# ╠═33654f91-0b61-4b39-b0fb-ef21776f0dfc
# ╟─52a049a9-c50f-426c-83e5-4ec02d5a638c
# ╠═56558e41-e3ae-42e5-8695-3d2077cbc10c
# ╠═c1059a32-8d65-4957-989f-2c5b5f50eb81
# ╟─b1aa765e-7a6b-4ab4-af83-ab3d30497866
# ╠═a767d45f-a438-4d87-bdab-7d55ea7458ac
# ╠═403f2e6c-5dec-4206-a5c0-d4a90fafc029
# ╠═f56a567b-62db-43b6-8dce-db9d5ca1e348
# ╠═b4b31659-8dc9-4837-8a6f-8d40b41b2366
# ╟─f71923d4-fbc9-4ce6-b5be-a00437c3651d
# ╟─18edd949-ce86-431a-a19b-4daf526e57a6
# ╠═d69b0cfe-ce30-420d-a891-c6e35e11cdde
# ╠═c1e29f52-424b-4cb2-814e-b4aecda86bc6
# ╠═7606f18e-9833-48cd-8c21-b48be30ef6f8
# ╟─dc4feb58-d2cf-4a97-aaed-7f4593fc9732
# ╠═607000ef-fb7f-4204-b543-3cb6bb75ed71
# ╠═b899a93f-9bec-48ce-b0ad-4e5157556a31
# ╠═42644265-8f26-4118-9e8f-537078847af7
# ╟─f5749121-8e75-45de-95b9-63fff584e350
# ╟─66e36fb8-5a61-49a7-8053-911fd887b0a9
# ╠═91e5840a-8a18-4d36-8fce-510af4c7dcf2
# ╠═4a807c44-f33e-4a58-99b3-261c392be891
# ╠═b5f3c2b1-c86a-48e4-973b-ee639d784936
# ╟─db28bb45-3418-4080-a0fc-9136fc0196a5
# ╟─494fc7d7-c622-41d1-91d8-3dc1fbd2f244
# ╟─4e1ac5fc-c684-42e1-9c99-3120021eb19a
# ╟─56b32132-113f-459f-b1d9-abb8f439a40b
# ╠═4931adf1-8771-4708-833e-d05c05884969
# ╟─0b07b9cf-83b4-46e9-9a75-cf2cadbbb011
# ╠═b814dc16-37de-45d1-9c7c-4eec45d3f956
# ╟─1572f901-c688-435e-81b9-d6e39bb82201
# ╠═b7faa3b7-e0b6-4f55-8763-035d8fc5ac93
# ╠═194d3a68-6bed-41d9-b3ea-8cfaf4787c54
# ╟─7285c7e8-bce0-42f0-a53b-562a8a6c5894
# ╟─b9f0e9b6-c111-4d69-990f-02c460c8706d
# ╟─114c048f-f619-4e15-8e5a-de852b0a1861
# ╟─7578be43-8dbe-4041-adc7-275f06057bfe
# ╠═69298293-c9fc-432f-9c3c-5da7ce710334
# ╠═9b9e5fc3-a8d0-4c42-91ae-25dd01bc7d7e
# ╟─54af5dab-e669-45eb-b6b5-44c46f7258b4
# ╠═842df050-e0be-441d-b84e-7f0575eac227
# ╠═36fcfd5e-c521-42fc-96cd-93787e657627
# ╠═f1da5c61-9862-44f6-84e4-96217736e1cb
# ╠═363af09c-3cc9-440d-9b70-1da8f6a70913
# ╟─bd705ddd-0d00-41a0-aa55-e82daad4133d
# ╟─d8052188-f2fa-4ad8-935f-581eea164bda
# ╠═1e08b49d-03fe-4fb3-a8ba-3a00e1374b32
# ╟─44442c34-e088-493a-bfd6-9c095c499100
# ╠═26c40cf4-9585-4762-abf4-ff77342a389f
# ╠═86872f35-d62d-40e5-8770-4585d3b0c0d7
# ╠═86fc7924-2002-4ac6-8e02-d9bf5edde9bf
# ╟─d72d9c99-6280-49a2-9f7a-e9628f1069eb
# ╠═0649437a-4198-4556-97dc-1b5cfbe45eed
# ╟─3928e9f7-9539-4d99-ac5b-6336eff8a523
# ╠═5ce7fbad-af38-4ff6-adca-b1991f3be455
# ╠═0dd8e1bf-f8c0-4183-a5eb-13eeb5316a7b
# ╠═7a320b75-c104-43d1-9129-f7f53910f5bc
# ╠═c1b73208-f917-4823-bf45-d896f4ee59e0
# ╠═4444622b-ccfe-4867-b659-489573099f1e
# ╟─a610dc3c-803a-4489-a84b-8bff415bc0a6
# ╠═c1942ee2-c5af-4b2b-986d-6ad563ef27bb
# ╟─0e99048d-5696-43ab-8896-301f37a20a5d
# ╟─bd012d84-a79f-4043-961e-f7825b7e0d6c
# ╟─03f6d241-712d-4a45-b926-09be326c1c7d
# ╟─e9507958-cefd-4208-896e-860d3e4e9d4b
# ╠═8acebedb-3a97-4efd-bd3c-c267ecd3945c
# ╠═32fdcdd9-785d-427b-94c3-3c65bf72e673
# ╠═8ce88d4d-59b0-49bb-8c0a-3a2961e5fd4a
# ╟─613269ef-16ba-44ef-ad8e-997cc9aec1fb
# ╟─fdd28672-5902-474a-8c87-3f6f38bcf54f
# ╟─54697e82-ee8c-4b65-a633-b29a47fac722
# ╠═0af6bce6-bc3b-438e-a57b-0c0c6586c0c5
# ╠═b5286a91-597d-4b66-86b2-1528708dfa93
# ╠═c3442bea-4ba9-4711-8d70-0ddd1745dd58
# ╟─24b95ecb-0df7-4af2-9d7e-c76ce380c6a6
# ╠═21b97f3d-85c8-420b-a884-df4fed98b8d0
# ╠═83180cd9-21b1-4e70-8d54-4bf03efa31be
# ╟─73cbbbd0-8427-46d3-896b-7cfc732c35f7
# ╠═f90fd2b4-7aec-40f5-85b7-00674582a902
# ╠═a05e3426-f014-473c-aad1-1cc6351a8911
# ╠═ba09be29-2af6-432e-871b-0637c52c68cf
# ╠═7a4156bd-5316-43ca-9cdc-d7e39f3c152f
# ╠═82ab5eed-eefe-4421-9a1e-7c3b0eea0523
# ╠═e16e9464-0a27-49ef-9b17-5ea850d253b4
# ╠═f761b97e-f1cb-406a-b0e9-75e4ec665097
# ╠═f714edaa-ba9a-46eb-89f0-5bcc4120015e
# ╠═1b7f3578-1de5-498c-b70f-9b4aa20d2edd
# ╟─c1da4130-5936-499f-bb9b-574e01136eca
# ╟─b16f6225-1949-4b6d-a4b0-c5c230eb4c7f
# ╠═dad5cba4-9bc6-47c3-a932-f2cc496b0f40
# ╠═9f027cde-dba0-4da5-8c42-5fa79b3929d6
# ╠═f1ba3d3c-d0a5-4290-ab73-9ce34bd5e5f6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
