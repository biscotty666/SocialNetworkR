# Signed Networks


[Source](https://schochastics.github.io/R4SNA/descriptive/signed-networks.html)

``` r
options(paged.print = FALSE)
```

``` r
libraries <- list(
  "igraph", "networkdata", "signnet",
  "patchwork", "ggraph"
)
invisible(lapply(libraries, library, character.only = TRUE))
```

Signed networks capture “negative” connections, eg. dislikes as well as
likes.

# Basics

Requires an `igraph` object with an edge attribute `sign` which is 1 for
positive and -1 for negative. Signed networks are represented by a
signed adjacency matrix.

We will use the tribes dataset to illustrate some basic functionality of
the package. This dataset is a signed social network of sixteen tribes
from the Gahuku-Gama alliance structure of the Eastern Central Highlands
of New Guinea. Tribes are connected by friendship ties (“rova”) and
enmity ties (“hina”).

``` r
ggsigned(tribes)
```

![](SignedNetworks_files/figure-commonmark/signed-networks-1-1.png)

With `weights = TRUE`, negative ties are stretched apart.

``` r
ggsigned(tribes, weights = TRUE)
```

![](SignedNetworks_files/figure-commonmark/signed-networks-2-1.png)

``` r
as_adj_signed(tribes)
```

          Gavev Kotun Ove Alika Nagam Gahuk Masil Ukudz Notoh Kohik Geham Asaro
    Gavev     0     1  -1    -1    -1    -1     0     0     0     0     0    -1
    Kotun     1     0  -1     0    -1    -1     0     0    -1    -1     0     0
    Ove      -1    -1   0     1     0     1     1     1     0     0     0     0
    Alika    -1     0   1     0     0     0     0     1     0     0     0     0
    Nagam    -1    -1   0     0     0     0     1     0     1     0     0     0
    Gahuk    -1    -1   1     0     0     0     1     1    -1     0     1     1
    Masil     0     0   1     0     1     1     0     1     0     0     1     1
    Ukudz     0     0   1     1     0     1     1     0     0     0     1     1
    Notoh     0    -1   0     0     1    -1     0     0     0     1    -1     0
    Kohik     0    -1   0     0     0     0     0     0     1     0    -1     0
    Geham     0     0   0     0     0     1     1     1    -1    -1     0     1
    Asaro    -1     0   0     0     0     1     1     1     0     0     1     0
    Uheto     0     0   0     0     0    -1     1     0     1     1    -1     0
    Seuve     0     0   0     0     1     0     0    -1     0     0     0    -1
    Nagad     1     1   0     0    -1     0     0     0    -1    -1    -1    -1
    Gama      1     1   0     0    -1    -1     0     0     0     0    -1    -1
          Uheto Seuve Nagad Gama
    Gavev     0     0     1    1
    Kotun     0     0     1    1
    Ove       0     0     0    0
    Alika     0     0     0    0
    Nagam     0     1    -1   -1
    Gahuk    -1     0     0   -1
    Masil     1     0     0    0
    Ukudz     0    -1     0    0
    Notoh     1     0    -1    0
    Kohik     1     0    -1    0
    Geham    -1     0    -1   -1
    Asaro     0    -1    -1   -1
    Uheto     0     1    -1   -1
    Seuve     1     0     0   -1
    Nagad    -1     0     0    1
    Gama     -1    -1     1    0

# Structural balance

Four possible configurations of three nodes are possible. Two are
*balanced*, two are *unbalanced*. Balanced configurations are all
friends or “the enemy of my enemy is my friend”, ie. two enemy ties and
one friend tie. A network is balanced if it can be partitioned into two
groups such that all ties within groups are positive and all ties
between groups are negative.

``` r
make_signed_triangle <- function(signs) {
  g <- make_graph(c(1, 2, 2, 3, 1, 3), directed = FALSE)
  E(g)$sign <- signs
  g
}

plot_triangle <- function(g, title) {
  E(g)$col <- ifelse(E(g)$sign == 1, "#104E8B", "firebrick3")
  edge_labels <- ifelse(E(g)$sign == 1, "+", "\u2013")
  ggraph(g, layout = "manual", x = c(-1, 1, 0), y = c(0, 0, sqrt(3))) +
    geom_edge_link(
      aes(label = edge_labels, edge_color = I(col)),
      edge_width = 1.2,
      label_size = 6,
      angle_calc = "across",
      label_push = unit(-3, "mm")
    ) +
    geom_node_point(size = 5, color = "grey30") +
    theme_graph() +
    theme(plot.title = element_text(hjust = 0.5, size = 11))
}

t1 <- make_signed_triangle(c(1, 1, 1))
t2 <- make_signed_triangle(c(-1, -1, 1))
t3 <- make_signed_triangle(c(1, 1, -1))
t4 <- make_signed_triangle(c(-1, -1, -1))

p1 <- plot_triangle(t1, "+++") +
  theme(axis.title.x = element_text(face = "bold", size = 12)) +
  scale_x_continuous(name = "balanced")
p2 <- plot_triangle(t2, "+\u2013\u2013") +
  theme(axis.title.x = element_text(face = "bold", size = 12)) +
  scale_x_continuous(name = "balanced")
p3 <- plot_triangle(t3, "++\u2013") +
  theme(axis.title.x = element_text(face = "bold", size = 12)) +
  scale_x_continuous(name = "unbalanced")
p4 <- plot_triangle(t4, "\u2013\u2013\u2013") +
  theme(axis.title.x = element_text(face = "bold", size = 12)) +
  scale_x_continuous(name = "unbalanced")


p1 + p2 + p3 + p4 + plot_layout(ncol = 2, axis = "collect_x")
```

<div id="fig-balance-triples">

![](SignedNetworks_files/figure-commonmark/fig-balance-triples-1.png)

Figure 1: The four possible signed triangles and their balancedness.

</div>

Create a simple balanced network. If more than two islands are created,
they are clusterable into more than two groups with the same
relationship.

``` r
g_bal <- sample_islands_signed(
  islands.n = 2,
  islands.size = 10,
  islands.pin = 0.8,
  n.inter = 5
)
ggsigned(g_bal)
```

![](SignedNetworks_files/figure-commonmark/signed-networks-3-1.png)

Verify that all triangles are balanced.

``` r
count_signed_triangles(g_bal)
```

    +++ ++- +-- --- 
    123   0   7   0 

Real-world networks are rarely perfectly balanced, so one of three
scoring methods can be used, with 0 perfectly unbalanced and 1 perfectly
balanced.

- `triangles` returns the fraction of balanced triangles
- `walk` uses eigenvalues of the signed and unsigned adjacency matrices
  to capture balance at all scales not just triangles
- `frustration` finds a partition and counts how many edges violate the
  balance pattern. Finding the optimal partition is computationally
  hard. For exact results, use `frustration_exact()`.

``` r
balance_score(g_bal, method = "triangles")
```

    [1] 1

``` r
balance_score(g_bal, method = "walk")
```

    [1] 1

``` r
balance_score(g_bal, method = "frustration")
```

    [1] 1

``` r
balance_score(tribes, method = "triangles")
```

    [1] 0.8676471

``` r
balance_score(tribes, method = "walk")
```

    [1] 0.3575761

``` r
balance_score(tribes, method = "frustration")
```

    [1] 0.7586207

# Blockmodeling

Balanced networks can be partitioned into groups with positive
intra-group and negative inter-group ties. `signed_blockmodel()`
partitions a network into `k` predefined blocks, optimizing for such
structure by optimizing $P(C) = \alpha N + (1-\alpha)P$ where $N$ is the
total number of negative ties within blocks and $P$ is the total number
of positive ties between blocks. `alpha` near 1 prioritizes negative
ties within blocks, near 0 priorities positive ties between blocks.

Attemps to divide `tribes` into three blocks.

``` r
set.seed(1108)
clu <- signed_blockmodel(tribes, k = 3,
                         alpha = 0.5, annealing = T)
clu$membership
```

     [1] 2 2 1 1 3 1 1 1 3 3 1 1 3 3 2 2

``` r
clu$criterion
```

    [1] 2

2 edges violate the criterion, and can be seen here.

``` r
ggblock(tribes, clu$membership, show_blocks = T)
```

![](SignedNetworks_files/figure-commonmark/signed-networks-4-1.png)

The function signed_blockmodel_general() allows us to specify arbitrary
block structures via the blockmat parameter. Each entry in the matrix
indicates whether we expect the corresponding block to be positive (1)
or negative (-1).

In the following we construct a synthetic network with three groups,
with a structure which cannot be captured by the traditional blockmodel
but can be specified in the general blockmodel.

``` r
g1 <- g2 <- g3 <- make_full_graph(5)
V(g1)$name <- as.character(1:5)
V(g2)$name <- as.character(6:10)
V(g3)$name <- as.character(11:15)

g <- Reduce("%u%", list(g1, g2, g3))
E(g)$sign <- 1
E(g)$sign[1:10] <- -1
g <- add_edges(g, c(rbind(1:5, 6:10)), attr = list(sign = -1))
g <- add_edges(g, c(rbind(1:5, 11:15)), attr = list(sign = -1))
g <- add_edges(g, c(rbind(11:15, 6:10)), attr = list(sign = 1))
ggsigned(g, weights = T)
```

<div id="fig-general-setup">

![](SignedNetworks_files/figure-commonmark/fig-general-setup-1.png)

Figure 2: A synthetic network with a non-standard block structure.

</div>

Groups 2 and 3 have positive ties between them, while both have negative
ties to group 1. The block structure matrix reflecting this is

``` r
set.seed(1108)
(blockmat <- matrix(
  c(1, -1, -1, -1, 1, 1, -1, 1, -1),
  3, 3, byrow = T
))
```

         [,1] [,2] [,3]
    [1,]    1   -1   -1
    [2,]   -1    1    1
    [3,]   -1    1   -1

``` r
general <- signed_blockmodel_general(g, blockmat, alpha = 0.5)
general$criterion
```

    [1] 0

``` r
ggblock(g, general$membership, show_blocks = TRUE)
```

<div id="fig-general-blockmodel">

![](SignedNetworks_files/figure-commonmark/fig-general-blockmodel-1.png)

Figure 3: Block structure of the synthetic network with a non-standard
block structure.

</div>

Without specifying the correct block structure, the results are poor.

``` r
traditional <- signed_blockmodel(
  g, k = 3, alpha = 0.5, annealing = TRUE
  )
c(general = general$criterion, 
  traditional = traditional$criterion)
```

        general traditional 
              0           6 

# Centrality

Indices must not just count ties but consider negative ties differently
than positive ties. Four variants are possible.

- `type = "pos"`: count only positive neighbors
- `type = "neg"`: count only negative neighbors
- `type = "ratio"`: positive neighbors / (positive + negative neighbors)
- `type = "net"`: positive neighbors minus negative neighbors

Directed networks also use `mode` to distinguish “in” and “out” version.

``` r
data.frame(
  tribe = V(tribes)$name,
  pos = degree_signed(tribes, type = "pos"),
  neg = degree_signed(tribes, type = "neg"),
  ratio = round(degree_signed(tribes, type = "ratio"), 2),
  net = degree_signed(tribes, type = "net")
)
```

          tribe pos neg ratio net
    Gavev Gavev   3   5  0.38  -2
    Kotun Kotun   3   5  0.38  -2
    Ove     Ove   4   2  0.67   2
    Alika Alika   2   1  0.67   1
    Nagam Nagam   3   4  0.43  -1
    Gahuk Gahuk   5   5  0.50   0
    Masil Masil   7   0  1.00   7
    Ukudz Ukudz   6   1  0.86   5
    Notoh Notoh   3   4  0.43  -1
    Kohik Kohik   2   3  0.40  -1
    Geham Geham   4   5  0.44  -1
    Asaro Asaro   4   4  0.50   0
    Uheto Uheto   4   4  0.50   0
    Seuve Seuve   2   3  0.40  -1
    Nagad Nagad   3   6  0.33  -3
    Gama   Gama   3   6  0.33  -3

*PN index* takes into account indirect as well as direct ties.
*Eigenvector centrality* considers a node central is it is connected to
other central nodes.

``` r
(cent_df <- data.frame(
  tribe = V(tribes)$name,
  degree_net = degree_signed(tribes, type = "net"),
  eigen = round(eigen_centrality_signed(tribes), 3),
  pn = round(pn_index(tribes), 3)
))
```

          tribe degree_net eigen    pn
    Gavev Gavev         -2 1.000 0.753
    Kotun Kotun         -2 0.889 0.764
    Ove     Ove          2 0.716 1.042
    Alika Alika          1 0.368 1.023
    Nagam Nagam         -1 0.743 0.903
    Gahuk Gahuk          0 0.955 0.905
    Masil Masil          7 0.760 1.224
    Ukudz Ukudz          5 0.671 1.141
    Notoh Notoh         -1 0.211 0.874
    Kohik Kohik         -1 0.239 0.903
    Geham Geham         -1 0.696 0.865
    Asaro Asaro          0 0.914 0.934
    Uheto Uheto          0 0.234 0.916
    Seuve Seuve         -1 0.059 0.875
    Nagad Nagad         -3 0.912 0.715
    Gama   Gama         -3 0.987 0.715

To see how much the measures agree

``` r
cor(eigen_centrality_signed(tribes), pn_index(tribes), method = "kendall")
```

    [1] -0.2

# Example - International Relations

The `cowList` dataset (included in the `signnet` package; see Doreian
and Mrvar (2015)) contains 51 signed networks of inter-state relations
in overlapping four-year windows from 1946 to 1999, derived from the
Correlates of War project. Two countries are connected by a positive tie
if they formed an alliance or signed a peace treaty, and by a negative
tie if they were at war or involved in other conflicts.

``` r
names(cowList)[c(1, 20, 51)]
```

    [1] "46-49" "65-68" "96-99"

Each network covers a four-year window (e.g., “65-68” covers 1965–1968).
Let us examine two snapshots: one from the height of the Cold War and
one from the post-Cold War period.

``` r
cowList <- lapply(cowList, upgrade_graph)

cow_cold <- cowList[["65-68"]]
cow_post <- cowList[["93-96"]]

c(
  nodes_cold = vcount(cow_cold),
  edges_cold = ecount(cow_cold),
  nodes_post = vcount(cow_post),
  edges_post = ecount(cow_post)
)
```

    nodes_cold edges_cold nodes_post edges_post 
           107        590        148       1181 

``` r
data.frame(
  method = c("triangles", "walk", "frustration"),
  cold_war = c(
    balance_score(cow_cold, method = "triangles"),
    balance_score(cow_cold, method = "walk"),
    balance_score(cow_cold, method = "frustration")
  ),
  post_cold_war = c(
    balance_score(cow_post, method = "triangles"),
    balance_score(cow_post, method = "walk"),
    balance_score(cow_post, method = "frustration")
  )
)
```

           method  cold_war post_cold_war
    1   triangles 0.9450199     0.9264774
    2        walk 0.6916381     0.2566049
    3 frustration 0.8983051     0.8933108

The expectation during the Cold War is that there would be blocks
corresponding to Western and Eastern alliances.

``` r
set.seed(1108)
clu_cold <- signed_blockmodel(cow_cold, k = 2,
                              alpha = 0.5, annealing = T)
ggblock(cow_cold, clu_cold$membership, show_blocks = T)
```

![](SignedNetworks_files/figure-commonmark/signed-networks-6-1.png)

``` r
split(V(cow_cold)$name, clu_cold$membership)
```

    $`1`
     [1] "ALG" "ARG" "AUS" "BAR" "BEL" "BOL" "BRA" "CAN" "CAF" "CHA" "CHL" "COL"
    [13] "CON" "COS" "CYP" "CZE" "DEN" "DOM" "ECU" "EGY" "ELS" "ETH" "FRA" "GAB"
    [25] "GFR" "GHA" "GRC" "GUA" "HAI" "HON" "ICE" "IND" "IRN" "IRQ" "ITA" "CDI"
    [37] "JPN" "JOR" "KEN" "KUW" "LAO" "LEB" "LYB" "LUX" "MYS" "MLI" "MAS" "MEX"
    [49] "MON" "MOR" "NDL" "NZD" "NIC" "NOR" "PAK" "PAN" "PAR" "PER" "PHL" "PRG"
    [61] "RVN" "SAU" "SAF" "KOR" "ESP" "SUD" "SYR" "TWN" "THA" "TRI" "TUN" "TUR"
    [73] "GBR" "USA" "URU" "VZA" "YAR" "YUG" "ZIM"

    $`2`
     [1] "AFG" "ALB" "BUL" "BUI" "CMB" "CHN" "CUB" "DRC" "FIN" "GDR" "GUI" "GUY"
    [13] "HUN" "INS" "ISR" "MAG" "MYR" "NEP" "NKR" "POL" "ROM" "RUS" "RWA" "SOM"
    [25] "TGO" "UGA" "VTN" "ZAM"
