package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"sort"
	"strings"
	"time"
)

type Author struct {
	Login string `json:"login"`
}

type Review struct {
	Author      Author     `json:"author"`
	Body        string     `json:"body"`
	SubmittedAt *time.Time `json:"submittedAt"`
}

type Comment struct {
	Author    Author     `json:"author"`
	Body      string     `json:"body"`
	CreatedAt *time.Time `json:"createdAt"`
}

type PR struct {
	Number         int       `json:"number"`
	Title          string    `json:"title"`
	Author         Author    `json:"author"`
	URL            string    `json:"url"`
	ReviewDecision *string   `json:"reviewDecision"`
	IsDraft        bool      `json:"isDraft"`
	CreatedAt      time.Time `json:"createdAt"`
	UpdatedAt      time.Time `json:"updatedAt"`
	Reviews        []Review  `json:"reviews"`
}

type PRWithComments struct {
	PR
	LatestCommentTime *time.Time `json:"latestCommentTime"`
	ReviewCount       int        `json:"reviewCount"`
	CommentCount      int        `json:"commentCount"`
}

type PRDetails struct {
	Comments []Comment `json:"comments"`
	Reviews  []Review  `json:"reviews"`
}

func main() {
	var (
		comment    string
		repo       string
		format     string
		help       bool
		showHelp   bool
	)

	flag.StringVar(&comment, "c", "", "PRのコメントに含まれるテキストで検索")
	flag.StringVar(&comment, "comment", "", "PRのコメントに含まれるテキストで検索")
	flag.StringVar(&repo, "r", "", "対象リポジトリ (owner/repo)")
	flag.StringVar(&repo, "repo", "", "対象リポジトリ (owner/repo)")
	flag.StringVar(&format, "f", "table", "出力フォーマット: table, json")
	flag.StringVar(&format, "format", "table", "出力フォーマット: table, json")
	flag.BoolVar(&help, "h", false, "このヘルプメッセージを表示")
	flag.BoolVar(&showHelp, "help", false, "このヘルプメッセージを表示")
	flag.Parse()

	if help || showHelp {
		printHelp()
		return
	}

	// リポジトリが指定されていない場合は現在のリポジトリを取得
	if repo == "" {
		currentRepo, err := getCurrentRepo()
		if err != nil {
			fmt.Println("エラー: リポジトリが指定されておらず、現在のディレクトリもgitリポジトリではありません。")
			fmt.Println("-r オプションでリポジトリを指定するか、gitリポジトリ内で実行してください。")
			os.Exit(1)
		}
		repo = currentRepo
	}

	fmt.Printf("リポジトリ: %s\n", repo)
	fmt.Println("検索中...")
	fmt.Println()

	// PRリストを取得
	prs, err := getPRList(repo)
	if err != nil {
		fmt.Printf("エラー: PRの取得に失敗しました: %v\n", err)
		os.Exit(1)
	}

	// REVIEW_REQUIRED かつ isDraft が false のPRのみを抽出
	filteredPRs := []PR{}
	for _, pr := range prs {
		if pr.ReviewDecision != nil && *pr.ReviewDecision == "REVIEW_REQUIRED" && !pr.IsDraft {
			filteredPRs = append(filteredPRs, pr)
		}
	}

	// 各PRのコメント情報を取得
	prsWithComments := []PRWithComments{}
	for _, pr := range filteredPRs {
		details, err := getPRDetails(repo, pr.Number)
		if err != nil {
			// エラーの場合はコメント情報なしで続行
			prsWithComments = append(prsWithComments, PRWithComments{
				PR:                pr,
				LatestCommentTime: nil,
				ReviewCount:       0,
				CommentCount:      0,
			})
			continue
		}

		// コメント検索が指定されている場合のフィルタリング
		if comment != "" {
			found := false
			for _, c := range details.Comments {
				if strings.Contains(c.Body, comment) {
					found = true
					break
				}
			}
			if !found {
				for _, r := range details.Reviews {
					if strings.Contains(r.Body, comment) {
						found = true
						break
					}
				}
			}
			if !found {
				continue
			}
		}

		// 最新のコメント時間を取得
		var latestTime *time.Time
		allTimes := []time.Time{}
		
		for _, c := range details.Comments {
			if c.CreatedAt != nil {
				allTimes = append(allTimes, *c.CreatedAt)
			}
		}
		for _, r := range details.Reviews {
			if r.SubmittedAt != nil {
				allTimes = append(allTimes, *r.SubmittedAt)
			}
		}
		
		if len(allTimes) > 0 {
			sort.Slice(allTimes, func(i, j int) bool {
				return allTimes[i].After(allTimes[j])
			})
			latestTime = &allTimes[0]
		}

		prsWithComments = append(prsWithComments, PRWithComments{
			PR:                pr,
			LatestCommentTime: latestTime,
			ReviewCount:       len(details.Reviews),
			CommentCount:      len(details.Comments),
		})
	}

	// コメントフィルタのメッセージ
	if comment != "" {
		fmt.Printf("コメントフィルタ: \"%s\"\n\n", comment)
	}

	// 結果がない場合
	if len(prsWithComments) == 0 {
		fmt.Println("条件に一致するPRが見つかりませんでした。")
		return
	}

	// 出力
	if format == "json" {
		outputJSON(prsWithComments)
	} else {
		outputTable(prsWithComments, repo)
	}
}

func printHelp() {
	fmt.Println("gh-pr-unapproved - レビューが必要な(REVIEW_REQUIRED)PRの情報を表示")
	fmt.Println()
	fmt.Println("使い方: gh-pr-unapproved [オプション]")
	fmt.Println()
	fmt.Println("オプション:")
	fmt.Println("  -c, --comment TEXT     PRのコメントに含まれるテキストで検索")
	fmt.Println("  -r, --repo OWNER/REPO  対象リポジトリ (デフォルト: 現在のリポジトリ)")
	fmt.Println("  -f, --format FORMAT    出力フォーマット: table, json (デフォルト: table)")
	fmt.Println("  -h, --help             このヘルプメッセージを表示")
	fmt.Println()
	fmt.Println("例:")
	fmt.Println("  gh-pr-unapproved                               # 現在のリポジトリのレビューが必要なPRを表示")
	fmt.Println("  gh-pr-unapproved -c \"LGTM\"                     # \"LGTM\"を含むコメントがあるPR")
	fmt.Println("  gh-pr-unapproved -r owner/repo -f json         # 指定リポジトリのPRをJSON形式で出力")
}

func getCurrentRepo() (string, error) {
	cmd := exec.Command("gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner")
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(output)), nil
}

func getPRList(repo string) ([]PR, error) {
	cmd := exec.Command("gh", "pr", "list",
		"--repo", repo,
		"--state", "open",
		"--limit", "20",
		"--json", "number,title,author,url,reviewDecision,isDraft,createdAt,updatedAt,reviews",
	)
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	var prs []PR
	if err := json.Unmarshal(output, &prs); err != nil {
		return nil, err
	}
	return prs, nil
}

func getPRDetails(repo string, prNumber int) (*PRDetails, error) {
	cmd := exec.Command("gh", "pr", "view",
		fmt.Sprintf("%d", prNumber),
		"--repo", repo,
		"--json", "comments,reviews",
	)
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	var details PRDetails
	if err := json.Unmarshal(output, &details); err != nil {
		return nil, err
	}
	return &details, nil
}

func formatTimeAgo(t *time.Time) string {
	if t == nil {
		return "No comments"
	}

	now := time.Now()
	diff := now.Sub(*t)

	switch {
	case diff < time.Minute:
		return fmt.Sprintf("%ds ago", int(diff.Seconds()))
	case diff < time.Hour:
		return fmt.Sprintf("%dm ago", int(diff.Minutes()))
	case diff < 24*time.Hour:
		return fmt.Sprintf("%dh ago", int(diff.Hours()))
	case diff < 7*24*time.Hour:
		return fmt.Sprintf("%dd ago", int(diff.Hours()/24))
	default:
		return fmt.Sprintf("%dw ago", int(diff.Hours()/(24*7)))
	}
}

func outputTable(prs []PRWithComments, repo string) {
	fmt.Println("Review Required PRs:")
	fmt.Println("====================")
	fmt.Println()

	// ヘッダー
	fmt.Printf("%-8s %-35s %-12s %-8s %-8s %-12s %-50s\n", "PR#", "Title", "Author", "Comments", "Reviews", "Last updated", "URL")
	fmt.Printf("%-8s %-35s %-12s %-8s %-8s %-12s %-50s\n", "---", "-----", "------", "--------", "-------", "------------", "---")

	// 各PRを表示
	for _, pr := range prs {
		title := pr.Title
		if len(title) > 35 {
			title = title[:35]
		}

		commentsDisplay := fmt.Sprintf("%d", pr.CommentCount)
		reviewsDisplay := fmt.Sprintf("%d", pr.ReviewCount)

		timeAgo := formatTimeAgo(pr.LatestCommentTime)

		fmt.Printf("%-8s %-35s %-12s %-8s %-8s %-12s %-50s\n",
			fmt.Sprintf("#%d", pr.Number),
			title,
			"@"+pr.Author.Login,
			commentsDisplay,
			reviewsDisplay,
			timeAgo,
			pr.URL,
		)
	}

	fmt.Println()
	fmt.Printf("詳細を見るには: gh pr view <PR番号> --repo %s\n", repo)
}

func outputJSON(prs []PRWithComments) {
	// 経過時間を追加
	type PRWithTimeAgo struct {
		PRWithComments
		LatestCommentTimeAgo string `json:"latestCommentTimeAgo"`
	}

	output := make([]PRWithTimeAgo, len(prs))
	for i, pr := range prs {
		output[i] = PRWithTimeAgo{
			PRWithComments:       pr,
			LatestCommentTimeAgo: formatTimeAgo(pr.LatestCommentTime),
		}
	}

	encoder := json.NewEncoder(os.Stdout)
	encoder.SetIndent("", "  ")
	encoder.Encode(output)
}
