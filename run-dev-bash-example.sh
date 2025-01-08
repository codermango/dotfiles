#!/usr/bin/env bash

set -e  # 脚本中任何命令失败，立即退出
set -o pipefail  # 管道中任意命令失败都视为失败

# 1. 检查并安装 GNU parallel
if ! command -v parallel &> /dev/null; then
    echo "GNU parallel 未安装，正在尝试安装..."

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y parallel
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install parallel
    else
        echo "不支持的系统类型，请手动安装 GNU parallel。" >&2
        exit 1
    fi

    echo "GNU parallel 安装完成！"
fi

# 2. 设置 GCP 项目
GCP_PROJECT="king-foundry-dev"
echo "设置 GCP 项目为: $GCP_PROJECT"
gcloud config set project $GCP_PROJECT || { echo "设置 GCP 项目失败"; exit 1; }

# 2. 更新 Application Default Credentials (ADC)
echo "更新 Application Default Credentials..."
gcloud auth application-default login --quiet || {
    echo "ADC 更新失败，请检查权限。"
    exit 1
}

# 验证 ADC 项目是否一致
ADC_PROJECT=$(gcloud auth list --filter="status:ACTIVE" --format="value(account)")
echo "当前 ADC 账号: $ADC_PROJECT"

# 2. 定义密钥名称与环境变量的映射表
# declare -A SECRET_MAP=(
#     ["foundry-dev-github-token"]="GHE_TOKEN"
#     ["foundry-dev-ldap-secret"]="LDAP_SECRET"
#     ["docs-dev-docs-sql-password"]="UP_CLIENT_SECRET"

#     ["foundry-dev-github-client-id"]="GITHUB_CLIENT_ID"
#     ["foundry-dev-github-secret"]="GITHUB_CLIENT_SECRET"
#     ["foundry-dev-google-client-id"]="AUTH_GOOGLE_CLIENT_ID"
#     ["foundry-dev-google-client-secret"]="AUTH_GOOGLE_CLIENT_SECRET"
#     ["foundry-dev-sonarqube-token"]="SONARQUBE_TOKEN"
#     ["foundry-dev-argocd-token"]="ARGOCD_AUTH_TOKEN"
#     ["foundry-dev-jira-token"]="JIRA_TOKEN"
#     ["foundry-dev-kingfluence-token"]="KINGFLUENCE_TOKEN"
#     ["foundry-dev-pagerduty-token"]="PAGERDUTY_TOKEN"
#     ["foundry-dev-kingquestions-token"]="KINGQUESTIONS_AUTH_TOKEN"
#     ["foundry-dev-danswer-token"]="DANSWER_TOKEN"
#     ["foundry-dev-danswer-api-key"]="DANSWER_API_KEY"
#     ["foundry-dev-openai-api-key"]="OPENAI_KEY"
#     ["foundry-dev-observatory-token"]="OBSERVATORY_TOKEN"
# )

# 2. 定义密钥名称与环境变量的映射表 (使用文本列表)
SECRET_MAP="foundry-dev-github-token:GHE_TOKEN
foundry-dev-ldap-secret:LDAP_SECRET
foundry-dev-github-client-id:GITHUB_CLIENT_ID
foundry-dev-github-secret:GITHUB_CLIENT_SECRET
foundry-dev-google-client-id:AUTH_GOOGLE_CLIENT_ID
foundry-dev-google-client-secret:AUTH_GOOGLE_CLIENT_SECRET
foundry-dev-sonarqube-token:SONARQUBE_TOKEN
foundry-dev-argocd-token:ARGOCD_AUTH_TOKEN
foundry-dev-jira-token:JIRA_TOKEN
foundry-dev-kingfluence-token:KINGFLUENCE_TOKEN
foundry-dev-pagerduty-token:PAGERDUTY_TOKEN
foundry-dev-kingquestions-token:KINGQUESTIONS_AUTH_TOKEN
foundry-dev-danswer-token:DANSWER_TOKEN
foundry-dev-danswer-api-key:DANSWER_API_KEY
foundry-dev-openai-api-key:OPENAI_KEY
foundry-dev-observatory-token:OBSERVATORY_TOKEN"

# 3. 拉取密钥并设置为环境变量
echo "从 Secret Manager 拉取密钥并设置环境变量..."

# 临时文件缓存密钥结果
TEMP_FILE=$(mktemp)

echo "$SECRET_MAP" | parallel --colsep ':' '
    SECRET_NAME={1}
    ENV_VAR_NAME={2}
    SECRET_VALUE=$(gcloud secrets versions access latest --secret="$SECRET_NAME" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "$ENV_VAR_NAME=$SECRET_VALUE" >> '"$TEMP_FILE"'
    else
        echo "拉取密钥失败: $SECRET_NAME" >&2
        exit 1
    fi
'

# 5. 导入密钥到环境变量
echo "加载密钥到环境变量..."
while IFS="=" read -r KEY VALUE; do
    export "$KEY=$VALUE"
done < "$TEMP_FILE"

rm -f "$TEMP_FILE"

echo "所有密钥已成功加载。"

# echo $UP_CLIENT_SECRET

# 6. 启动 yarn dev
echo "启动 yarn dev..."
yarn dev
