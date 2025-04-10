#!/usr/bin/env python3

import argparse
import os
from typing import List, TypedDict

from github import Github
from github.PullRequest import PullRequest


class GitHubPullRequest(TypedDict):
    title: str
    html_url: str
    number: int
    state: str

def get_unapproved_pull_requests(owner: str, repo: str, token: str) -> List[GitHubPullRequest]:
    # GitHub クライアントの初期化
    g = Github(token)
    
    # リポジトリの取得
    repo = g.get_repo(f"{owner}/{repo}")
    
    # 未承認の Pull Request をフィルタリング
    unapproved_prs: List[GitHubPullRequest] = []
    for pr in repo.get_pulls(state='open'):
        reviews = pr.get_reviews()
        approved = any(review.state == 'APPROVED' for review in reviews)
        if not approved:
            unapproved_prs.append({
                'title': pr.title,
                'html_url': pr.html_url,
                'number': pr.number,
                'state': pr.state
            })

    return unapproved_prs

def main():
    parser = argparse.ArgumentParser(description='GitHub 未承認の Pull Request を抽出するスクリプト')
    parser.add_argument('--owner', required=True, help='リポジトリのオーナー名')
    parser.add_argument('--repo', required=True, help='リポジトリ名')
    parser.add_argument('--token', required=False, help='GitHub API トークン', default=os.getenv('GITHUB_TOKEN'))

    args = parser.parse_args()

    unapproved_prs = get_unapproved_pull_requests(args.owner, args.repo, args.token)

    for pr in unapproved_prs:
        print(f"Title: {pr['title']}, URL: {pr['html_url']}")

if __name__ == '__main__':
    main()
