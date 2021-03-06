#!/bin/bash

# DevOntheRun INIT Project Script

exec 0< /dev/tty

.shub/bin/shub-logo.sh

echo "---------------------------------------------"

read -r -p "Config template? [Y/n] " response
response=${response,,} # tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    
    clear

    echo "#############################################"
    echo "                   INIT                   "
    echo "#############################################"

    VERSION=$(head -n 1 .shub/bin/version)

    readValues() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
            PROJECT_REPO_LINK=$(git config --get remote.origin.url)
            PROJECT_REPO_NAME=$(basename `git rev-parse --show-toplevel`)
            GIT_BRANCH=$(git branch --show-current)
            GIT_USERNAME=$(git config user.name)

            function extractUserFromGitHubLInk () {
                # url="git://github.com/some-user/my-repo.git"
                # url="https://github.com/some-user/my-repo.git"
                # url="git@github.com:some-user/my-repo.git"
                url=$1
                re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+).git$"

                if [[ $url =~ $re ]]; then    
                    protocol=${BASH_REMATCH[1]}
                    separator=${BASH_REMATCH[2]}
                    hostname=${BASH_REMATCH[3]}
                    user=${BASH_REMATCH[4]}
                    repo=${BASH_REMATCH[5]}

                    GITHUB_USER=$user
                fi
            }

            extractUserFromGitHubLInk $PROJECT_REPO_LINK
        else
            PROJECT_REPO_LINK="{{ REPLACE_WITH_YOUR_REPO_LINK }}"
            PROJECT_REPO_NAME="{{ REPLACE_WITH_YOUR_REPO_NAME }}"
            GIT_BRANCH=""
            GIT_USERNAME="{{ REPLACE_WITH_YOUR_NAME }}"
        fi

        echo ""
        echo "---------------------------------------------"
        echo "Type some infos about the course below"
        echo "---------------------------------------------"
        echo ""

        PROJECT_DEFAULT_NAME=${PROJECT_REPO_NAME//-/ } # Replace all '-' with ' '
        PROJECT_DEFAULT_NAME=( $PROJECT_DEFAULT_NAME ) # without quotes
        PROJECT_DEFAULT_NAME="${PROJECT_DEFAULT_NAME[@]^}" # cap first letter
        printf 'Project name [%s]: ' "$PROJECT_DEFAULT_NAME"
        read -r PROJECT_NAME
        [ -z "$PROJECT_NAME" ] && PROJECT_NAME="$PROJECT_DEFAULT_NAME"

        printf 'Course name: '
        read -r COURSE_NAME

        printf 'Course link: '
        read -r COURSE_LINK

        printf 'Course type [class]: '
        read -r COURSE_TYPE
        [ -z "$COURSE_TYPE" ] && COURSE_TYPE="class"

        COURSE_MULTIPLE='true'
        read -r -p "This course will be unique? [Y/n] " response
        [[ $response =~ ^(yes|y|YES|Y| ) ]] || [[ -z $response ]] && COURSE_MULTIPLE='false'

        SHUB_VERSION='true'
        read -r -p "Remove ShubcoGen from app version control? [Y/n] " response
        [[ $response =~ ^(yes|y|YES|Y| ) ]] || [[ -z $response ]] && SHUB_VERSION='false' && echo ".shub" >> .gitignore

JSON_TEMPLATE='{
    "version": "%s",
    "username": "%s",
    "github_username": "%s",
    "project_name": "%s",
    "project_repo_name": "%s",
    "project_repo_link": "%s",
    "course_name": "%s",
    "course_link": "%s",
    "course_type": "%s",
    "course_multiple": "%s",
    "vcs": "%s"
}\n'
        JSON_CONFIG=$(printf "$JSON_TEMPLATE" "$VERSION" "$GIT_USERNAME" "$GITHUB_USER" "$PROJECT_NAME" "$PROJECT_REPO_NAME" "$PROJECT_REPO_LINK" "$COURSE_NAME" "$COURSE_LINK" "$COURSE_TYPE" "$COURSE_MULTIPLE" "$SHUB_VERSION")
    }

    if [ -f "shub-config.json" ]; then
        echo "shub-config.json detected"
        read -r -p "Use shub-config.json configs? [Y/n] " response
        response=${response,,} # tolower
        if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
            function parse_json()
            {
                echo $1 | \
                sed -e 's/[{}]/''/g' | \
                sed -e 's/", "/'\",\"'/g' | \
                sed -e 's/" ,"/'\",\"'/g' | \
                sed -e 's/" , "/'\",\"'/g' | \
                sed -e 's/","/'\"---SEPERATOR---\"'/g' | \
                awk -F=':' -v RS='---SEPERATOR---' "\$1~/\"$2\"/ {print}" | \
                sed -e "s/\"$2\"://" | \
                tr -d "\n\t" | \
                sed -e 's/\\"/"/g' | \
                sed -e 's/\\\\/\\/g' | \
                sed -e 's/^[ \t]*//g' | \
                sed -e 's/^"//'  -e 's/"$//' | \
                sed -e 's/"//' | \
                sed -e 's/ $//'
            }

            # Read json file content
            JSON_CONFIG="$(cat shub-config.json)"

            #version=$(parse_json "$JSON_CONFIG" version)
            GIT_USERNAME=$(parse_json "$JSON_CONFIG" username)
            GITHUB_USER=$(parse_json "$JSON_CONFIG" github_username)
            PROJECT_NAME=$(parse_json "$JSON_CONFIG" project_name)
            PROJECT_REPO_NAME=$(parse_json "$JSON_CONFIG" project_repo_name)
            PROJECT_REPO_LINK=$(parse_json "$JSON_CONFIG" project_repo_link)
            COURSE_NAME=$(parse_json "$JSON_CONFIG" course_name)
            COURSE_LINK=$(parse_json "$JSON_CONFIG" course_link)
            COURSE_TYPE=$(parse_json "$JSON_CONFIG" course_type)
            COURSE_MULTIPLE=$(parse_json "$JSON_CONFIG" course_multiple)
            VCS=$(parse_json "$JSON_CONFIG" vcs)
        else
            readValues
        fi
    else 
        readValues
    fi

    echo ""
    echo "---------------------------------------------"

    echo $JSON_CONFIG

    echo "---------------------------------------------"
    echo ""

    read -r -p "Accept configs? [Y/n] " response
    response=${response,,} # tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        # Update template
        sed -i "s/{{ PROJECT_NAME }}/$PROJECT_NAME/g" README.md
        sed -i "s/{{ COURSE_NAME }}/$COURSE_NAME/g" README.md
        sed -i "s,{{ COURSE_LINK }},$COURSE_LINK,g" README.md
        sed -i "s,{{ COURSE_TYPE }},$COURSE_TYPE,g" README.md
        sed -i "s/{{ PROJECT_REPO_NAME }}/$PROJECT_REPO_NAME/g" README.md
        sed -i "s/{{ GITHUB_USER }}/$GITHUB_USER/g" README.md
        sed -i "s/{{ GIT_USERNAME }}/$GIT_USERNAME/g" README.md
        sed -i "s/{{ VERSION }}/$VERSION/g" README.md

# Save JSON config file
cat <<EOF > shub-config.json
$JSON_CONFIG
EOF
    fi

    read -r -p "Keep shub scripts (deploy, init, self-update...)? [Y/n] " response
    response=${response,,} # tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        echo "OK =)"

        # Auto init first new branch based on course type
        if git rev-parse --git-dir > /dev/null 2>&1; then
            [[ $COURSE_MULTIPLE = 'true' ]] && FIRST_BRANCH_NAME="${COURSE_TYPE}-1.1" || FIRST_BRANCH_NAME="${COURSE_TYPE}-1"
            read -r -p "Checkout to new branch ($FIRST_BRANCH_NAME)? [Y/n] " response
            response=${response,,} # tolower
            if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
                git checkout -b $FIRST_BRANCH_NAME
                echo "## ${FIRST_BRANCH_NAME^^}" >> notes.md
                echo "" >> notes.md
            fi
        fi
    else
        rm -rf .shub
        rm shub-deploy.sh
    fi

    echo "---------------------------------------------"
    echo ""
    echo -e "\xE2\x9C\x94 CONFIGURATION COMPLETED"
    echo ""
    echo "---------------------------------------------"


else
    exit 0;
fi
