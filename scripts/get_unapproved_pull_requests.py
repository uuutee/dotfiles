import argparse
import os

import requests


def get_unapproved_pull_requests(owner, repo, token):
    # API ヘッダー
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json',
    }

    # Pull Request を取得するための URL
    url = f'https://api.github.com/repos/{owner}/{repo}/pulls'

    # Pull Request を取得
    response = requests.get(url, headers=headers)
    pull_requests = response.json()

    # 未承認の Pull Request をフィルタリング
    unapproved_prs = []
    for pr in pull_requests:
        reviews_url = pr['url'] + '/reviews'
        reviews_response = requests.get(reviews_url, headers=headers)
        reviews = reviews_response.json()
        approved = any(review['state'] == 'APPROVED' for review in reviews)
        if not approved:
            unapproved_prs.append(pr)

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
