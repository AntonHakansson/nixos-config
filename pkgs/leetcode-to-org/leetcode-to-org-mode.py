#!/usr/bin/env python

import sys
import requests
import json
import pypandoc

def fetchProblem(titleSlug):
    graphql_endpoint = 'https://leetcode.com/graphql/'

    body = """
      query consolePanelConfig($titleSlug: String!) {
        question(titleSlug: $titleSlug) {
          questionId
          questionTitle
          questionTitleSlug
          difficulty
          topicTags { slug }
          content
          exampleTestcaseList
          codeSnippets { langSlug code }
        }
      }
    """
    response = requests.get(url=graphql_endpoint, json={"query": body, "variables": { "titleSlug": titleSlug }})

    if response.status_code == 200:
        return json.loads(response.content.decode('utf-8'))
    else:
        sys.exit("response : ", response.content)

def questionAsOrg(out, q, langSlug):
    # org heading
    out.write('* ')
    out.write('{}. [[https://leetcode.com/problems/{}][{}]]'.format(q['questionId'], q['questionTitleSlug'], q['questionTitle']))

    tags = [ q['difficulty'].lower() ]
    tags.extend(t['slug'].lower().replace('-', "") for t in q['topicTags'])
    out.write(' ' * 4)
    for tag in tags:
        out.write(':{}'.format(tag))
    out.write(':')

    out.write('\n')
    out.write(':PROPERTIES:\n')
    out.write(':CUSTOM_ID: {}\n'.format(q['questionTitleSlug']))
    out.write(':END:\n')
    out.write('\n')

    # content
    out.write("#+begin_quote\n")
    content = pypandoc.convert_text(q['content'], 'org', format='html')
    content = content.replace(" ", "") # remove the weird unicode character
    out.write(content)
    out.write("#+end_quote\n\n")

    # solution
    out.write('#+begin_src C\n')
    for code in q['codeSnippets']:
        if code['langSlug'] == langSlug:
            out.write(code['code'])
            break
    out.write('\n#+end_src\n')

# Parse arguments
if len(sys.argv) < 2:
    sys.exit('Must pass leetode title-slug')
leetcodeTitleSlug = sys.argv[1]

# Convert to org-mode
problemRaw = fetchProblem(leetcodeTitleSlug)
questionAsOrg(sys.stdout, problemRaw['data']['question'], 'c')
