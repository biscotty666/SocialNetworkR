# Stochastic Actor Oriented Models (SAOMs)


[Source](https://schochastics.github.io/R4SNA/inferential/saom.html)

``` r
options(paged.print = FALSE)
```

``` r
libraries <- list(
  "igraph", "ggraph","graphlayouts",
  "networkdata", "intergraph", "RSiena",
  "tidyverse", "zeallot"
)
invisible(lapply(libraries, library, character.only = TRUE))
```

Stochastic Actor-Oriented Models (SAOMs) are explicitly designed for
longitudinal network data. This allows researchers to address questions
such as:

- How often do actors initiate or terminate ties?
- Do actors prefer to form ties based on similarity (selection) or
  become more similar after forming ties (influence)?
- How do structural tendencies like reciprocity or transitivity manifest
  through sequential decision-making?
- Can we simulate or predict how the network may evolve in future time
  points?

**Temporal Exponential Random Graph Models (TERGM)** can also be used,
but SOAM’s focus on process, how ties change due to actor decisions.

# Running Example: Teenage Friends and Lifestyle Study

We use a running example with data from the “Teenage Friends and
Lifestyle Study” \[@west1996s50\], which was also used in the previous
chapter on ERGMs. In contrast to the earlier example that focused on a
single time point and only the subset of 50 pupils, we here model the
dynamics of friendship ties across all three observed waves and with the
129 pupils over all three time points, and including relevant
actor-level covariates such as gender and smoking behavior. The dataset
is called `glasgow129` in the `networkdata` package, which includes the
following:

- Networks: Binary, directed friendship ties measured at three time
  points.
- Actors: 129 pupils measured at three time points.
- Many covariates, but we focus on
  - Sex: 1 = Male, 2 = Female
  - Smoking: 1 = No, 2 = Occasional, 3 = Regular

``` r
c(glasgow_g1, glasgow_g2, glasgow_g3) %<-% 
  map(1:3, \(i) glasgow129[[i]])
c(net1, net2, net3) %<-%
  map(list(glasgow_g1, glasgow_g2, glasgow_g3),
      \(x) as_adjacency_matrix(x, sparse = F))
net_array <- array(c(net1, net2, net3), dim = c(129, 129, 3))
```

# SAOM Framework

## Modeling Network Evolution

Longitudinal network data consist of a set of actors and a series of
observed adjacency matrices, each capturing ties at a particular point
in time.

These repeated measures make it possible to ask and answer key
questions:

- How frequently do actors change their ties?
- What drives the formation, maintenance, or dissolution of ties?
- How do individual attributes (e.g., gender, age, group membership)
  shape network dynamics?
- Can we predict how the network will evolve in the future?
- How do both endogenous (network-based) and exogenous (attribute-based)
  factors jointly shape the network?

Stochastic Actor-Oriented Models (SAOMs) offer a solution by treating
network change as a **continuous-time, actor-driven process**. In this
framework:

- The network evolves through a sequence of micro-steps where individual
  actors have opportunities to change their outgoing ties.
- Each actor evaluates the current network and makes decisions based on
  preferences (e.g., for reciprocation, closure, or similarity).
- The model simulates the timing and direction of these changes between
  observation moments (waves).

# Estimating SAOMs in RSiena

Can model network evolution and co-evolution of networks and behavior.
If only a network object is included, it captures how actors form,
maintain, or dissolve ties of time. Individual attributes are treated as
exogenous and fixed over time. It can explain **social selection**. If a
behavioral variable is included, it can also model change of behavior
over time, explaining **social influence**.

Below, we outline the typical steps involved in estimating SAOMs using
RSiena:

1.  **Preparing the data**  
    Import and format the network and covariate data into the
    appropriate structure. This includes creating adjacency matrices for
    networks observed over time and vectors or matrices for actor-level
    covariates. These are then converted into RSiena objects such as
    `sienaDependent`, `coCovar`, or `varCovar`.

2.  **Specifying the model**  
    Define the model by selecting the effects to include. Use
    `getEffects()` to retrieve the default effects object and
    `includeEffects()` to add endogenous and covariate-related effects.

3.  **Estimating the model**  
    Set up the estimation procedure using `sienaAlgorithmCreate()` and
    estimate the model with `siena07()`. Evaluate convergence and
    diagnostic statistics to ensure reliable results.

4.  **Interpreting the results**  
    Analyze the estimated parameters to understand the underlying social
    processes. This involves examining the direction, magnitude, and
    statistical significance of effects to interpret mechanisms of
    network change or co-evolution.

## Model 1: Structural Network Effects

The model includes outdegree and reciprocity effects, capturing a
baseline propensity for ties and mutual ties. These are endogenous
network dynamics.

Convert 3D network array to a `sienaDependent` object.

``` r
siena_net <- sienaDependent(net_array)
```

Wrap that into a complete `RSiena` object.

``` r
data_mod1 <- sienaDataCreate(siena_net)
```

List all possible effects available for the data structure.

``` r
(my_effects <- getEffects(data_mod1))
```

      effectName                         include fix   test  initialValue parm
    1 constant siena_net rate (period 1) TRUE    FALSE FALSE    7.45424   0   
    2 constant siena_net rate (period 2) TRUE    FALSE FALSE    6.82927   0   
    3 outdegree (density)                TRUE    FALSE FALSE   -1.61299   0   
    4 reciprocity                        TRUE    FALSE FALSE    0.00000   0   

Define the estimation algorithm. The `projname` argument specifies a
name for the project; RSiena will use this name to organize temporary
output files and logs related to the estimation.

``` r
my_algorithm <- sienaAlgorithmCreate(projname = "saom_1", seed = 1108)
```

This algorithm object is later passed into the siena07() function to
control how the estimation is performed. You can customize various
settings like number of iterations, convergence thresholds, or use
defaults (as we do here) for a basic estimation.

The siena07() function. This function runs the RSiena estimation
procedure. It takes the following inputs:

- my_algorithm: the algorithm settings we defined earlier.
- data = data_mod1: the network data in RSiena format.
- effects = my_effects: the specified model effects (in this case,
  outdegree and reciprocity).
- batch = TRUE: suppresses user prompts during the estimation, making it
  suitable for scripted or automated runs.

``` r
saom_1 <- siena07(
  my_algorithm,
  data = data_mod1,
  effects = my_effects,
  batch = TRUE, 
  useCluster = T, nbrNodes = 6
)
```

``` r
saom_1
```

    Estimates, standard errors and convergence t-ratios

                                       Estimate   Standard   Convergence 
                                                    Error      t-ratio   

    Rate parameters: 
      0.1      Rate parameter period 1  8.5815  ( 0.6791   )             
      0.2      Rate parameter period 2  7.2220  ( 0.5811   )             

    Other parameters: 
      1.  eval outdegree (density)     -2.4137  ( 0.0386   )    0.0067   
      2.  eval reciprocity              2.7092  ( 0.0836   )   -0.0135   

    Overall maximum convergence ratio:    0.0310 


    Total of 1685 iteration steps.

``` r
significance <- function(mod) {
  data.frame(
    effect = mod$effects$effectName,
    significance = abs(mod$theta / mod$se),
    gt.20 = ifelse(abs(mod$theta / mod$se) > 2, "Yes", "No")
  )
}
significance((saom_1))
```

                   effect significance gt.20
    1 outdegree (density)     62.45877   Yes
    2         reciprocity     32.38963   Yes

### Convergence assessment

Convergence is assessed using two main criteria

1.  Overall maximum convergence ratio. Values below 0.25 are considered
    acceptable, below 0.15 very good
2.  Individual convergence t-ratios. Below 0.20 is generally exceptable,
    below 0.10 are ideal

In this case, the diagnostics confirm that the estimation process
stabilized.

### Rate parameters

- Rate 1: On average, each actor had 8.6 opportunities to change ties
  between waves 1 and 2
- Rate 2: On average, each actor had 7.2 opportunities to change ties
  between waves 2 and 3

### Network dynamics

- Outdegree density - strong negative effect - actors are reluctant to
  form many ties and prefer sparser networks. Forming new ties carries a
  cost
- Reiprocity - strong positive effect - actors prefer to reciprocate
  existing ties

The objective function for actor $i$ can be written:

$$f_i(\theta, Y^{(a)}) =
\theta_{\text{out}} \sum_{j} y^{(a)}_{ij}
+
\theta_{\text{rec}} \sum_{j} y^{(a)}_{ij} \, y^{(a)}_{ji}$$

To understand this, consider two scenarios:

1.  **Adding a reciprocated tie**  
    Suppose $y_{ji}(t) = 1$ (the other actor has already sent a tie),
    and actor $i$ considers forming $y_{ij} = 1$. The change in utility
    is -2.415 + 2.711 = 0.296. This yields a **positive utility
    change**, making the move likely.

2.  **Adding a non-reciprocated tie**  
    If $y_{ji}(t) = 0$, the tie is not reciprocated. The utility change
    is -2.411. This is **negative**, making the change unlikely.

## Model 2: Structural and covariate effects

Incorporating covariates

into the objective function requires distinguishing between different
types of effects:

- **Ego effects**: How an actor’s own covariate value influences their
  tendency to form or maintain ties (e.g., do smokers send more ties?).
- **Alter effects**: How the recipient’s covariate value affects the
  likelihood of receiving a tie (e.g., are smokers more likely to be
  chosen as friends?).
- **Similarity effects**: Whether actors prefer to form ties with others
  who are similar to themselves (e.g., are adolescents more likely to
  befriend others with similar smoking behavior?).

In Model 2, we treat sex as a fixed covariate and smoking behavior as a
changing covariate observed at each wave. We include the following
additional effects:

- **Ego effect of smoking**: Does an adolescent’s smoking status
  influence how many ties they send?
- **Alter effect of smoking**: Are smokers more likely to receive ties?
- **Similarity in smoking**: Are adolescents more likely to form ties
  with others who have similar smoking behavior?
- **Sex effects**: Do patterns of tie formation differ by sex?

``` r
# Convert array into RSiena dependent object
siena_net <- sienaDependent(net_array)
```

Like before, this object represents the longitudinal network that serves
as the dependent variable in the SAOM. Different from before, we extract
covariate values from the network’s node attributes. Sex (`sex.F`) is
treated as a time-invariant covariate, while smoking behavior
(`familysmoking`) is treated as time-varying across the three network
waves.

Extract and recode sex to numeric, then convert to a covariate object.

``` r
sex_char <- V(glasgow_g2)$sex.F
sex_num <- ifelse(sex_char == "F", 1, ifelse(sex_char == "M", 0, NA))
sex_cov <- coCovar(sex_num)
```

Extract smoking behavior which is assumed to change.

``` r
c(smoke1, smoke2, smoke3) %<-%
  map(list(glasgow_g1, glasgow_g2, glasgow_g3),
      \(x) as.numeric(V(x)$tobacco))
smoking_array <- cbind(smoke1, smoke2, smoke3)
smoking_cov <- varCovar(smoking_array)
```

Combine network and covariates into Siena data object.

``` r
data_mod2 <- sienaDataCreate(siena_net, sex_cov, smoking_cov)
```

Define effects to be included, starting with default set. Add
structural, sex, and smoking effects.

``` r
my_effects <- getEffects(data_mod2) %>%
  includeEffects(
    outdegree, recip, transTrip
  ) %>%
  includeEffects(
    egoX, altX, simX,
    interaction1 = "sex_cov"
  ) %>%
  includeEffects(
    egoX, altX, simX,
    interaction1 = "smoking_cov"
  )
```

      effectNumber effectName          shortName include fix   test  initialValue
    1 17           reciprocity         recip     TRUE    FALSE FALSE          0  
    2 23           transitive triplets transTrip TRUE    FALSE FALSE          0  
      parm
    1 0   
    2 0   
      effectNumber effectName         shortName include fix   test  initialValue
    1 240          sex_cov alter      altX      TRUE    FALSE FALSE          0  
    2 255          sex_cov ego        egoX      TRUE    FALSE FALSE          0  
    3 301          sex_cov similarity simX      TRUE    FALSE FALSE          0  
      parm
    1 0   
    2 0   
    3 0   
      effectNumber effectName             shortName include fix   test 
    1 424          smoking_cov alter      altX      TRUE    FALSE FALSE
    2 439          smoking_cov ego        egoX      TRUE    FALSE FALSE
    3 485          smoking_cov similarity simX      TRUE    FALSE FALSE
      initialValue parm
    1          0   0   
    2          0   0   
    3          0   0   

Define estimation settings. and run model.

``` r
my_algorithm <- sienaAlgorithmCreate(projname = "saom_2", seed = 1108)

saom_2 <- siena07(
  my_algorithm,
  data = data_mod2,
  effects = my_effects,
  batch = T,
  useCluster = T, nbrNodes = 6
)
```

``` r
saom_2
```

    Estimates, standard errors and convergence t-ratios

                                       Estimate   Standard   Convergence 
                                                    Error      t-ratio   

    Rate parameters: 
      0.1      Rate parameter period 1 10.7021  ( 1.0508   )             
      0.2      Rate parameter period 2  8.9962  ( 0.8074   )             

    Other parameters: 
      1.  eval outdegree (density)     -2.8605  ( 0.0571   )   -0.0097   
      2.  eval reciprocity              1.9896  ( 0.0847   )   -0.0368   
      3.  eval transitive triplets      0.4467  ( 0.0266   )   -0.0322   
      4.  eval sex_cov alter           -0.1596  ( 0.1019   )   -0.0182   
      5.  eval sex_cov ego              0.1664  ( 0.0999   )    0.0220   
      6.  eval sex_cov similarity       0.9200  ( 0.1006   )   -0.0208   
      7.  eval smoking_cov alter        0.1047  ( 0.0598   )    0.0173   
      8.  eval smoking_cov ego          0.0749  ( 0.0633   )    0.0298   
      9.  eval smoking_cov similarity   0.3735  ( 0.1192   )   -0.0401   

    Overall maximum convergence ratio:    0.1371 


    Total of 1513 iteration steps.

``` r
significance(saom_2)
```

                      effect significance gt.20
    1    outdegree (density)    50.088635   Yes
    2            reciprocity    23.480384   Yes
    3    transitive triplets    16.772108   Yes
    4          sex_cov alter     1.566581    No
    5            sex_cov ego     1.665062    No
    6     sex_cov similarity     9.145398   Yes
    7      smoking_cov alter     1.749381    No
    8        smoking_cov ego     1.183375    No
    9 smoking_cov similarity     3.132826   Yes

### Convergence assessment

Individual and overall convergence t-ratios indicate good convergence.

### Rate parameters

Actors had about 11 opportunities to change between the first waves, and
9 chances to do so between the subsequent waves.

### Network dynamics

Again, reluctance to form many ties and tendency to reciprocity are
indicated. There is also a preference for triadic closure. This
represents sparsity, reciprocity and local clustering.

For covariate related effects:

Sex alter and sex ego are not statistically significant, indicating no
systematic preference or avoidance of alters based on sex, nor any
difference between males and females. However, there is a strong
tendency toward homophily.

The coefficient for sex similarity is 0.9200 (SE = 0.1006). The
coefficient is centered around the mean value.

``` r
mean(sex_cov)
```

    [1] 0.4341085

i.e., $\bar{v} = 0.434$. Thus, approximately 43.4% of actors in this
dataset are girls. In `RSiena`, covariates are mean-centered by default,
ensuring that estimated effects are interpreted relative to the average
actor.

With 0 for boys and 1 for girls, the centered values are

``` r
(sex_center <- tibble(
  sex = c("boy", "girl"),
  value = c((0 - mean(sex_cov)), (1 - mean(sex_cov))),
))
```

    # A tibble: 2 × 2
      sex    value
      <chr>  <dbl>
    1 boy   -0.434
    2 girl   0.566

Because covariates are mean-centered, the contribution of a potential
tie $y_{ij}$ to the objective function depends on these centered values.
The covariate-related part of the objective function for actor $i$, when
evaluating a candidate network $Y^{(a)}$, can be written as:

$$f_i(\theta, Y^{(a)}) =
\theta_{\text{ego}} (v_i - \bar{v}) \sum_{j} y^{(a)}_{ij}
\;+\;
\theta_{\text{alter}} \sum_{j} y^{(a)}_{ij} (v_j - \bar{v})
\;+\;
\theta_{\text{sim}} \sum_{j} y^{(a)}_{ij} \, I(v_i = v_j)$$

where:

- $v_i$ and $v_j$ are the covariate values (sex) for actors $i$ and $j$,
  respectively (coded as 0 = boy, 1 = girl),
- $\bar{v} = 0.434$ is the sample mean of the covariate,
- $y^{(a)}_{ij}$ indicates the presence of a tie from $i$ to $j$ in the
  candidate network $Y^{(a)}$,
- $I(v_i = v_j)$ is an indicator function equal to 1 if actors $i$ and
  $j$ share the same sex, and 0 otherwise.

``` r
center_sex <- function(mod, var) {
    c(
    round(mod$theta[var] * 
            sex_center[sex_center$sex == "boy", ]$value, 3),
    round(mod$theta[var] * 
            sex_center[sex_center$sex == "girl", ]$value, 3)
  )
}

c(ego_sex, alter_sex) %<-%
  map(c(5, 4),
      \(x) center_sex(saom_2, x))
sim_sex <- c(round(saom_2$theta[6], 3), 0)
```

Total contribution to the objective function is then

``` r
contribution <- function(ego_alt, ego_term, alt_term, sim_term) {
  length = length(ego_alt)
  tibble(
    ego = rep(ego_alt, each = length),
    alter = rep(ego_alt, length),
    ego_term = rep(ego_term, each = length),
    alter_term = rep(alt_term, length),
    similarity_term = sim_term
  ) %>%
    mutate(
      total_contribution = rowSums(across(where(is.numeric)))
    )
}

sim_term <- c(sim_sex, rev(sim_sex))

contribution(c("Male", "Female"), ego_sex, alter_sex, sim_term)
```

    # A tibble: 4 × 6
      ego    alter  ego_term alter_term similarity_term total_contribution
      <chr>  <chr>     <dbl>      <dbl>           <dbl>              <dbl>
    1 Male   Male     -0.072      0.069            0.92              0.917
    2 Male   Female   -0.072     -0.09             0                -0.162
    3 Female Male      0.094      0.069            0                 0.163
    4 Female Female    0.094     -0.09             0.92              0.924

These values show that same-sex ties, especially between girls, are more
likely due to the strong similarity effect. Cross-sex ties are less
likely, receiving lower utility in the objective function.

The smoking variable is ordinal with three categories: 1 = no smoking, 2
= occasional smoking, and 3 = regular smoking. The covariate is centered
by subtracting its mean. In this case, the mean value is computed in R
as:

Smoking is encoded 1 for non-smoker, 2 for occasional smoker, 3 for
regular smoker

``` r
mean(smoking_cov)
```

    [1] 1.377261

``` r
(smoke_center <- tibble(
  smokes = c("none", "occasional", "regular"),
  value = c((1 - mean(smoking_cov)), (2 - mean(smoking_cov)),
            (3 - mean(smoking_cov))),
))
```

    # A tibble: 3 × 2
      smokes      value
      <chr>       <dbl>
    1 none       -0.377
    2 occasional  0.623
    3 regular     1.62 

The contribution of a potential tie $y_{ij}(t)$ (from actor $i$ to actor
$j$) to the objective function is given by:

$$\theta_{\text{ego}}(v_i - \bar{v}) 
+ \theta_{\text{alter}}(v_j - \bar{v}) 
+ \theta_{\text{sim}} \left(1 - \frac{|v_i - v_j|}{R_v}\right)$$

where $R_v$ denotes the range of the covariate $v$ (here,
$R_v = 3 - 1 = 2$). Substituting the estimated parameter values from the
model:

$$0.077(v_i - 1.377) + 0.109(v_j - 1.377) 
+ 0.380 \left(1 - \frac{|v_i - v_j|}{2} \right)$$

This expression combines:

- an **ego effect**, capturing how smoking behavior influences how many
  ties actor $i$ tends to send,
- an **alter effect**, capturing how smoking behavior affects how
  attractive actor $j$ is as a recipient of ties,
- and a **similarity effect**, which rewards ties between actors with
  similar smoking levels.

``` r
center_smoke <- function(var) {
    c(
    round(saom_2$theta[var] * 
            smoke_center[smoke_center$smokes == "none", ]$value, 3),
    round(saom_2$theta[var] * 
            smoke_center[smoke_center$smokes == "occasional", ]$value, 3),
    round(saom_2$theta[var] * 
            smoke_center[smoke_center$smokes == "regular", ]$value, 3)
  )
}

c(ego_smoke, alter_smoke) %<-%
  map(c(8, 7), center_smoke)
```

The similarity term is partial for none/occasional and
occasional/regular.

``` r
(sim_smoke <- 
   c(
     round(saom_2$theta[9], 3),
     round(saom_2$theta[9] / 2, 3),
     0
   ))
```

    [1] 0.374 0.187 0.000

``` r
sim_term <- c(sim_smoke, sim_smoke[2],
                      sim_smoke[1], sim_smoke[2],
                      rev(sim_smoke))

contribution(c("None", "Occasional", "Regular"), 
             ego_smoke, alter_smoke, sim_term)
```

    # A tibble: 9 × 6
      ego        alter      ego_term alter_term similarity_term total_contribution
      <chr>      <chr>         <dbl>      <dbl>           <dbl>              <dbl>
    1 None       None         -0.028     -0.039           0.374              0.307
    2 None       Occasional   -0.028      0.065           0.187              0.224
    3 None       Regular      -0.028      0.17            0                  0.142
    4 Occasional None          0.047     -0.039           0.187              0.195
    5 Occasional Occasional    0.047      0.065           0.374              0.486
    6 Occasional Regular       0.047      0.17            0.187              0.404
    7 Regular    None          0.122     -0.039           0                  0.083
    8 Regular    Occasional    0.122      0.065           0.187              0.374
    9 Regular    Regular       0.122      0.17            0.374              0.666

**?@tbl-smokeeff** illustrates how these smoking-related covariate
effects contribute to the objective function. Each cell reports the
total contribution associated with a potential tie from ego $i$ to alter
$j$, given their respective smoking levels.

Actors with similar smoking behavior are more likely to form ties,
especially regular-to-regular smokers, indicating a strong homophily
pattern. The ego and alter terms slightly amplify or reduce this
tendency depending on individual smoking levels. Actors are increasingly
likely to form ties the more they smoke.

## Model 3: Network and Behavioral Co-Evolution

We now estimate a co-evolution model in which the friendship network and
smoking behavior are treated as jointly dependent processes. The network
process models changes in friendship ties, while the behavioral process
models changes in actors’ smoking behavior over time.

In this specification, smoking enters the model in two ways. First,
smoking is used in the network objective function to test selection
effects: whether actors form or maintain ties based on smoking behavior.
Second, smoking is modeled as a behavioral dependent variable to test
influence effects: whether actors adjust their smoking behavior in
response to their friends.

Dependent variables

``` r
siena_net <- sienaDependent(net_array)
smoking_beh <- sienaDependent(smoking_array, type = "behavior")
```

Covariate and datra object

``` r
sex_cov <- coCovar(sex_num)
data_coev <- sienaDataCreate(
  siena_net, smoking_beh, sex_cov
)
```

Effects

Network Dynamics

``` r
eff <- getEffects(data_coev) %>% 
  includeEffects(outdegree, recip, transTrip, name = "siena_net") %>% 
  includeEffects(egoX, altX, simX, 
                 name = "siena_net", interaction1 = "sex_cov") %>% 
  includeEffects(egoX, altX, simX, name = "siena_net",
                 interaction1 = "smoking_beh")
```

      effectNumber effectName          shortName include fix   test  initialValue
    1 17           reciprocity         recip     TRUE    FALSE FALSE          0  
    2 23           transitive triplets transTrip TRUE    FALSE FALSE          0  
      parm
    1 0   
    2 0   
      effectNumber effectName         shortName include fix   test  initialValue
    1 240          sex_cov alter      altX      TRUE    FALSE FALSE          0  
    2 255          sex_cov ego        egoX      TRUE    FALSE FALSE          0  
    3 301          sex_cov similarity simX      TRUE    FALSE FALSE          0  
      parm
    1 0   
    2 0   
    3 0   
      effectNumber effectName             shortName include fix   test 
    1 424          smoking_beh alter      altX      TRUE    FALSE FALSE
    2 439          smoking_beh ego        egoX      TRUE    FALSE FALSE
    3 485          smoking_beh similarity simX      TRUE    FALSE FALSE
      initialValue parm
    1          0   0   
    2          0   0   
    3          0   0   

Behavior dynamics - shape, position, social influence

``` r
eff <- eff %>% 
  includeEffects(linear, quad, name = "smoking_beh") %>% 
  includeEffects(indeg, outdeg, name = "smoking_beh",
                 interaction1 = "siena_net") %>% 
  includeEffects(avAlt, name = "smoking_beh", interaction1 = "siena_net")
```

      effectNumber effectName                  shortName include fix   test 
    1 658          smoking_beh linear shape    linear    TRUE    FALSE FALSE
    2 661          smoking_beh quadratic shape quad      TRUE    FALSE FALSE
      initialValue parm
    1   -0.58955   0   
    2    0.00000   0   
      effectNumber effectName            shortName include fix   test  initialValue
    1 711          smoking_beh indegree  indeg     TRUE    FALSE FALSE          0  
    2 714          smoking_beh outdegree outdeg    TRUE    FALSE FALSE          0  
      parm
    1 0   
    2 0   
      effectNumber effectName                shortName include fix   test 
    1 729          smoking_beh average alter avAlt     TRUE    FALSE FALSE
      initialValue parm
    1          0   0   

We define the estimation settings using `sienaAlgorithmCreate()` and
estimate the co-evolution model.

``` r
alg <- sienaAlgorithmCreate(projname = "saom_coev", seed = 1108)

saom_coev <- siena07(
  alg,
  data = data_coev,
  effects = eff,
  batch = TRUE
)
```

Finally, we display the model results.

``` r
saom_coev
```

    Estimates, standard errors and convergence t-ratios

                                                  Estimate   Standard   Convergence 
                                                               Error      t-ratio   
    Network Dynamics 
       1. rate constant siena_net rate (period 1) 10.7632  ( 1.1630   )    0.0591   
       2. rate constant siena_net rate (period 2)  9.0071  ( 0.8211   )   -0.0169   
       3. eval outdegree (density)                -2.8529  ( 0.0764   )   -0.0330   
       4. eval reciprocity                         1.9790  ( 0.1074   )    0.0058   
       5. eval transitive triplets                 0.4430  ( 0.0316   )   -0.0126   
       6. eval sex_cov alter                      -0.1734  ( 0.1028   )   -0.0772   
       7. eval sex_cov ego                         0.1835  ( 0.1053   )   -0.0070   
       8. eval sex_cov similarity                  0.9252  ( 0.1433   )    0.0664   
       9. eval smoking_beh alter                   0.1068  ( 0.0780   )    0.0258   
      10. eval smoking_beh ego                     0.0669  ( 0.0804   )    0.1212   
      11. eval smoking_beh similarity              0.5002  ( 0.1858   )   -0.0596   

    Behavior Dynamics
      12. rate rate smoking_beh (period 1)         4.3300  ( 1.8491   )   -0.0728   
      13. rate rate smoking_beh (period 2)         3.8654  ( 2.0209   )   -0.0651   
      14. eval smoking_beh linear shape           -4.0638  ( 0.7318   )   -0.0304   
      15. eval smoking_beh quadratic shape         2.7982  ( 0.3795   )    0.0381   
      16. eval smoking_beh indegree                0.1752  ( 0.1970   )   -0.0088   
      17. eval smoking_beh outdegree              -0.0498  ( 0.2317   )   -0.0511   
      18. eval smoking_beh average alter           1.7661  ( 0.7814   )    0.0518   

    Overall maximum convergence ratio:    0.5180 


    Total of 3602 iteration steps.

``` r
significance(saom_coev)
```

                                   effect significance gt.20
    1  constant siena_net rate (period 1)    9.2547156   Yes
    2  constant siena_net rate (period 2)   10.9692182   Yes
    3                 outdegree (density)   37.3434778   Yes
    4                         reciprocity   18.4309493   Yes
    5                 transitive triplets   14.0142368   Yes
    6                       sex_cov alter    1.6871512    No
    7                         sex_cov ego    1.7426710    No
    8                  sex_cov similarity    6.4551640   Yes
    9                   smoking_beh alter    1.3698683    No
    10                    smoking_beh ego    0.8311469    No
    11             smoking_beh similarity    2.6929510   Yes
    12        rate smoking_beh (period 1)    2.3416618   Yes
    13        rate smoking_beh (period 2)    1.9127368    No
    14           smoking_beh linear shape    5.5530803   Yes
    15        smoking_beh quadratic shape    7.3732219   Yes
    16               smoking_beh indegree    0.8894089    No
    17              smoking_beh outdegree    0.2148908    No
    18          smoking_beh average alter    2.2601027   Yes

The co-evolution model shows the following key patterns:

- **Network structure**
  - Strong negative outdegree $\Rightarrow$ sparse network
  - Strong positive reciprocity $\Rightarrow$ mutual ties are strongly
    favored
  - Positive transitivity $\Rightarrow$ evidence of triadic closure
- **Sex effects**
  - Strong positive similarity $\Rightarrow$ clear same-sex homophily
  - Ego and alter effects not significant $\Rightarrow$ no strong
    differences in tie activity by sex
- **Smoking and network selection**
  - Positive similarity effect $\Rightarrow$ friendships are formed
    between actors with similar smoking behavior (selection)
  - Ego and alter effects not significant $\Rightarrow$ smoking does not
    affect sending/receiving ties overall
- **Behavioral dynamics (smoking)**
  - Negative linear + positive quadratic shape $\Rightarrow$ tendency
    toward moderate smoking levels
  - Average alter effect positive and significant $\Rightarrow$ evidence
    of social influence (actors adjust smoking toward friends)
  - Indegree and outdegree effects not significant $\Rightarrow$ network
    position not strongly related to smoking

Overall, the results suggest that network evolution is primarily driven
by reciprocity, triadic closure, and homophily. In addition, there is
evidence for both selection and influence processes in the co-evolution
of networks and behavior: actors tend to form ties with others who have
similar smoking behavior, and they also adjust their behavior over time
to become more similar to their friends.
