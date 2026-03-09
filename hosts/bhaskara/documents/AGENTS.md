# Agents

- Name: OpenClaw
  Role: General assistant.
  Model: openai:glm-4-9b # vLLM often uses openai compatible provider
  SystemPromptFile: SOUL.md
  Tools:
    - shell
    - filesystem
    - calculator
