
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!--
### [stufield.github.io/COVID-19](https://stufield.github.io/COVID-19)
-->

# [The Monty Hall Paradox](https://stufield.github.io/monty-hall-paradox)

Suppose you’re on a game show, and you’re given the choice of three
doors: Behind one door is a car; behind the others are goats. You pick a
door, say `A`, and the host, who knows where the care is located, opens
another door, say `C`, which has a goat. He then asks you, “Do you want
to pick door `B`?” Is it to your advantage to switch your choice?

### Key Assumptions

For the paradox to work, there are some key assumptions (rules) about
the host’s behavior:

1.  The host must always open a door that was not picked by the
    contestant
2.  The host must always open a door to reveal a goat and never the car.
3.  The host must always offer the chance to switch between the
    originally chosen door and the remaining closed door.

### Common Mistake

Most people come to the conclusion that switching does not matter
because there are two unopened doors and one car and that it is a 50/50
choice. This would be true if the host opens a door randomly, but that
is not the case; the door opened depends on the player’s initial choice,
so the assumption of independence does not hold. As we see below,
breaking the independence assumption drastically alters the
probabilities of the remaining unrevealed doors.

-----

### Solution

The key insight is that the host does *not* reveal the remaining
(non-chosen) doors randomely. He *always* reveals a goat, and thus has
knowledge of where the car actually is. Incorporating this information
into the probability calculation adjusts the probability, shifting it
away from the newly revealed door to the remaining unrevealed and
unchosen door. In a way this represents a Bayesian update to the
probability of door `B` with the knowldege that the car is *not* behind
door `C`. The posterior probability of door `B` is updated from 0.33 -\>
0.66 following the reveal that door `C` is not an option.

| Door A | Door B | Door C | Stay Strategy | Switch Strategy |
| :----: | :----: | :----: | :-----------: | :-------------: |
|  Goat  |  Goat  |  Car   |   Wins goat   |    Wins car     |
|  Goat  |  Car   |  Goat  |   Wins goat   |    Wins car     |
|  Car   |  Goat  |  Goat  |   Wins car    |    Wins goat    |
|        |        |        | P(car) = 1/3  |  P(car) = 2/3   |

#### Visual: probability tree

![](monty-hall-tree.png)

-----

## Simple Simulation

Perhaps the easiest way to visualize the solution is through simulation.

### Code

``` r
# run a single Monty-Hall trial
mh <- function() {
  true       <- sample(doors, 1)                 # true correct door
  choose     <- sample(doors, 1)                 # player's door choice: 1/3
  notchoose  <- doors[doors != choose]           # doors not chosen
  switch_win <- as.numeric(true %in% notchoose)  # if truth not chosen; win by switching
  switch_win
}

doors   <- LETTERS[1:3]                          # doors 'A', 'B', and 'C'
trials  <- 150                                   # number of trials
sim_res <- tibble::tibble(
  n_sim           = seq_len(trials),
  switch_win      = replicate(n = trials, mh()),
  stay_win        = 1 - switch_win,
  sum_switch_wins = cumsum(switch_win),
  sum_stay_wins   = cumsum(stay_win),
  prob_switch_win = sum_switch_wins / (sum_switch_wins + sum_stay_wins),
  prob_stay_win   = 1 - prob_switch_win
)

# simulation results
sim_res
#> # A tibble: 150 x 7
#>    n_sim switch_win stay_win sum_switch_wins sum_stay_wins prob_switch_win
#>    <int>      <dbl>    <dbl>           <dbl>         <dbl>           <dbl>
#>  1     1          1        0               1             0           1    
#>  2     2          0        1               1             1           0.5  
#>  3     3          1        0               2             1           0.667
#>  4     4          0        1               2             2           0.5  
#>  5     5          1        0               3             2           0.6  
#>  6     6          0        1               3             3           0.5  
#>  7     7          1        0               4             3           0.571
#>  8     8          0        1               4             4           0.5  
#>  9     9          0        1               4             5           0.444
#> 10    10          1        0               5             5           0.5  
#> # … with 140 more rows, and 1 more variable: prob_stay_win <dbl>
```

### Plot Simulations

``` r
plotsim <- sim_res %>%
  tidyr::pivot_longer(
  cols     = c(sum_switch_wins, sum_stay_wins),
  names_to = "strategy", values_to = "Wins"
)

p1 <- plotsim %>%
  ggplot(aes(x = n_sim, y = Wins, color = strategy)) +
  geom_line(size = 1.5) +
  ggtitle("Cumulative Wins by Strategy") +
  labs(y = "Cumulative Wins", x = "Trial") +
  theme(legend.position = "top")

plotsim <- sim_res %>%
  tidyr::pivot_longer(
  cols     = c(prob_switch_win, prob_stay_win),
  names_to = "strategy", values_to = "prob"
)

p2 <- plotsim %>%
  ggplot(aes(x = n_sim, y = prob, color = strategy)) +
  geom_line(size = 1.25) +
  ylim(c(0, 1)) +
  geom_hline(yintercept = sim_res$prob_switch_win[trials], linetype = "dashed") +
  labs(y = "P(win)", x = "Trial",
       subtitle = sprintf("P(switch) = %0.2f", sim_res$prob_switch_win[trials])) +
  ggtitle("Probability of Winning by Strategy")

gridExtra::grid.arrange(p1, p2, ncol = 2)
```

![](figs/README-plot-sim-1.png)<!-- -->

-----

### Links

<https://en.wikipedia.org/wiki/Monty_Hall_problem>

-----

Created by [Rmarkdown](https://github.com/rstudio/rmarkdown) (v2.1) and
R version 3.6.3 (2020-02-29).
