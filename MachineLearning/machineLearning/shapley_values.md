How important is each player to the overall cooperation, and what payoff 
can he or she reasonably expect?

# Table of Contents

## 1) Formal definition
Let us define $P$ a set of players, $card(P) = n$, and a function such as $\nu: 2^{N} \rightarrow \mathbb{R}$ and $\nu(\empty) = 0$. 
If $S$ is a coalition of players, then $\nu(S)$, called the worth coalition $S$ describes the total expected sum of payoffs the members of $S$ can obtain by cooperation.
The Shapley value is one way to distribute the total gains to the players, assuming that they all collaborate. 
$$
\begin{align*}
\varphi(\nu) &= \displaystyle\sum_{S\subseteq N/\{i\}}
\dfrac{|S|!(n-|S|-1)!}{n!}\left[\nu(S\cup \{i\}) - \nu(S)\right]\\
             &=\displaystyle\sum_{S\subseteq N/\{i\}}
{n \choose 1, |S|, n- |S| -1}^{-1}\left[\nu(S\cup \{i\}) - \nu(S)\right]
\end{align*}
$$
The formula can be interpreted as follows: imagine the coalition being formed one actor at a time, with each actor demanding their contribution 
$\nu(S \cup \{i\}) - \nu{S}$ as a fair compensation, and then for each actor take the average of this contribution over the possible different permutations in which the coalition can be formed. 