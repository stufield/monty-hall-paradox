
# Single Monty-Hall trial; win by switching?
mh_switch_win <- function() {
  true   <- sample(1:3, 1L)
  choose <- sample(1:3, 1L)
  # if correct door not chosen; player wins by switching (TRUE/FALSE)
  true != choose
}

trials <- 100
sim_res <- withr::with_seed(8327, {
  tibble::tibble(
    n_sim           = seq_len(trials),
    switch_win      = replicate(n = trials, mh_switch_win()),
    stay_win        = !switch_win,
    sum_switch_wins = cumsum(switch_win),
    sum_stay_wins   = cumsum(stay_win),
    prob_switch_win = sum_switch_wins / (sum_switch_wins + sum_stay_wins),
    prob_stay_win   = 1 - prob_switch_win
  )
})

p1 <- sim_res |>
  tidyr::pivot_longer(
  cols     = c(sum_switch_wins, sum_stay_wins),
  names_to = "strategy", values_to = "Wins"
  ) |>
  ggplot(aes(x = n_sim, y = Wins, color = strategy)) +
  geom_line(size = 1.5) +
  ggtitle("Cumulative Wins by Strategy") +
  labs(y = "Cumulative Wins", x = "Trial Sim")

p2 <- sim_res |>
  tidyr::pivot_longer(
  cols     = c(prob_switch_win, prob_stay_win),
  names_to = "strategy", values_to = "prob"
  ) |>
  ggplot(aes(x = n_sim, y = prob, color = strategy)) +
  geom_line(size = 1.25) +
  ylim(c(0, 1)) +
  geom_hline(yintercept = sim_res$prob_switch_win[trials], linetype = "dashed") +
  labs(y = "P(win)", x = "Trial",
       subtitle = sprintf("P(switch win) = %0.2f", sim_res$prob_switch_win[trials])) +
  ggtitle("Probability of Winning by Strategy")

# ----------
library(patchwork)
p1 + p2

