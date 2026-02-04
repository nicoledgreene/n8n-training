class GitHubActionError {
  description = {
    displayName: "GitHub Action Error",
    name: "gitHubActionError",
    group: ["transform"],
    version: 1,
    description:
      "Fetches error information from GitHub Actions and suggests fixes",
    defaults: {
      name: "GitHub Action Error",
    },
    inputs: ["main"],
    outputs: ["main"],
    properties: [
      {
        displayName: "GitHub API Token",
        name: "githubApiToken",
        type: "string",
        default: "",
        typeOptions: { password: true },
        required: true,
      },
      {
        displayName: "Repository Owner",
        name: "owner",
        type: "string",
        default: "",
        required: true,
      },
      {
        displayName: "Repository Name",
        name: "repo",
        type: "string",
        default: "",
        required: true,
      },
      {
        displayName: "Run ID",
        name: "runId",
        type: "string",
        default: "",
        required: true,
      },
    ],
  };

  async execute() {
    const items = this.getInputData();
    const returnData = [];

    for (let i = 0; i < items.length; i++) {
      try {
        const githubApiToken = this.getNodeParameter("githubApiToken", i);
        const owner = this.getNodeParameter("owner", i);
        const repo = this.getNodeParameter("repo", i);
        const runId = this.getNodeParameter("runId", i);

        const options = {
          method: "GET",
          url: `https://api.github.com/repos/${owner}/${repo}/actions/runs/${runId}/logs`,
          headers: {
            "User-Agent": "n8n",
            Authorization: `token ${githubApiToken}`,
            Accept: "application/vnd.github+json",
          },
          encoding: null,
        };

        const response = await this.helpers.request(options);

        // TODO: unzip + parse response (it's a ZIP)
        const errorMessage = "Sample error message from logs";

        returnData.push({
          json: {
            error: errorMessage,
            suggestion: "Possible fix for the error.",
          },
        });
      } catch (error) {
        if (this.continueOnFail()) {
          returnData.push({ json: { error: error.message } });
          continue;
        }
        throw error;
      }
    }

    return this.prepareOutputData(returnData);
  }
}

module.exports = { GitHubActionError };
