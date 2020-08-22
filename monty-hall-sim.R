
mh <- function() {
  true       <- sample(doors, 1)                 # true correct door
  choose     <- sample(doors, 1)                 # player's door choice: 1/3
  notchoose  <- doors[doors != choose]           # doors not chosen
  switch_win <- as.numeric(true %in% notchoose)  # if truth not chosen; win by switching
  switch_win
}

doors  <- LETTERS[1:3]
trials <- 100
set.seed(8327)
sim_res <- tibble::tibble(
  n_sim = seq_len(trials),
  switch_win = replicate(n = trials, mh()),
  stay_win   = 1 - switch_win,
  sum_switch_wins = cumsum(switch_win),
  sum_stay_wins = cumsum(stay_win),
  prob_switch_win = sum_switch_wins / (sum_switch_wins + sum_stay_wins),
  prob_stay_win = 1 - prob_switch_win
)

p1 <- tidyr::pivot_longer(
  sim_res,
  cols = c(sum_switch_wins, sum_stay_wins),
  names_to = "strategy", values_to = "Wins"
  ) %>%
  ggplot(aes(x = n_sim, y = Wins, color = strategy)) +
  geom_line(size = 1.5) +
  ggtitle("Cumulative Wins by Strategy") +
  labs(y = "Cumulative Wins", x = "Trial Sim")
p1

p2 <- tidyr::pivot_longer(
  sim_res,
  cols = c(prob_switch_win, prob_stay_win),
  names_to = "strategy", values_to = "prob"
  ) %>%
  ggplot(aes(x = n_sim, y = prob, color = strategy)) +
  geom_line(size = 1.25) +
  ylim(c(0, 1)) +
  geom_hline(yintercept = sim_res$prob_switch_win[trials], linetype = "dashed") +
  labs(y = "P(success)", x = "Trial Sim") +
  ggtitle(
    sprintf("Probability of Winning via Switching (P = %0.2f)",
            sim_res$prob_switch_win[trials]))
p2
