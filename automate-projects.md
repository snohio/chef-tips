# Playing with Automate Projects

## Case Statement

I would like to learn how to use Projects to separate Orgs so that teams can use Automate for Read (and Admin) and only have access to their Org.

> DISCLAIMER: While this document has tokens in it, they were only good for that instance of the Automate demo that was build and by the time of this posting, that instance has been destroyed.

## Configuration Items

- [x] Build the Automate / Infra server from Terraform / Azure
- [X] Set up multiple orgs
- [X] Bootstrap windows servers to org 2
- [X] Create four additional users
  - [X] Infra only for it_devops `it-devops-oper`
  - [X] Admin for it_devops `it-devops-admin`
  - [X] Infra only for devops_it `devops-it-oper`
  - [X] Admin for devops_it `devops-it-admin`
- [ ] Add Teams here if you want and put the users into the Teams
- [X] Create Project for each Org
  - [X] Check the Also create owner, editor and view policies. (We'll change these later)
  - [X] Set the Ingest Rules to filter on *Node / Chef Org*
- [X] Create two role. You will need to do this via API. More below.
  - [X] `devops-viewer`
  - [X] `devops-admin`
- [X] Modify the four Policies via API (see below) to align to the Roles we just created. (You can use the OOB, but they grant too much access for my liking in general.)
- [X] Configure **Chef Infra Servers** configuration to be aligned to a Project.
- [X] Verify that those can only see the nodes in those orgs
- [X] Admin for devops_it should only have access to Infra/Chef Infra Servers for the devops_it org.

## How to create and modify policies

1. Get your admin token from Automate under Settings / API Tokens. Click the `...` and select **Copy Token**.
2. Use a tool like **Postman** to interact with the API.
3. For Roles, the URI is like: `https://snohio.azure.chef-demo.com/apis/iam/v2/roles`.
4. Add in your Authorization token with the Key being `api-token` and add to Header.
5. From here you can do a GET and hit Send. This should return all ROLES and details.
6. To create a NEW Role, select Body and type raw with the content JSON.
7. Paste the Role(s) below and then change GET to POST and hit SEND.
8. If you want to make changes, you will use the URI for that ROLE such as `https://snohio.azure.chef-demo.com/apis/iam/v2/roles/devops-viewer`. Best to get the data from a GET and then paste it into your Body, remove `type` and modify any of the other fields you need. You will also need to remove the `"role": {` and the ending `}` and tab stuff to the left. Then change GET to PUT. This will modify the settings. We'll do this for Policies below because we had them created when we created the **Project**.

> As I documented below, it is going to be a good idea to keep a copy of your json somewhere. It is easy to blow it away if you accidentally do a PUT instead of a GET. Ask me how I know.

9. We need to update our Policies that were created as a part of that **Project** creation. I am somewhat second-guessing creating them at the time of the **Project** creation because we need to make changes anyway and just doing a POST with the right information is just as easy. In this use case / example, we'll be deleting the Editors policy as we aren't using it.

> Policies are where you define Users and what Role then belong to and what Project they see the systems of. You will need a **Policy** for each **Project** (so for each Org for instance if that is the goal) but you only need a **Role** for each definition of what you want the users to be able to see and do.

10. In Postman you can copy your current tab to a new one to play with Policies. This will pull over your api-token and other settings. Then change your URI to the like: `https://snohio.azure.chef-demo.com/apis/iam/v2/policies` and then do a **GET**.
11. If you need to create a NEW policy, use the json payload below and then use a **POST**. Remember raw/JSON as your Body config. As in the examples below, you will need your user accounts created prior to the creation. You CAN assign USERS to Policies within Automate itself.
12. If you are going to modify an existing policy, you can use Automate to copy the existing policy then take that output and past it into your *Body* in Postman. You will need to specify the URI for the specific policy such as `https://snohio.azure.chef-demo.com/apis/iam/v2/policies/devops_it-project-owners` and then **PUT** and *Send*. Remember, **PUT** updates using the URI with the ID and **POST** creates at the root of the /policies URI.
13. At this point, you should be able to log in as the user(s) that you created and get the results you desire.

> Also, after some more thought, in this simple demo, we are using individuals and putting them in Roles. If you are going to have multiple users for a project and don't want to update the Policy each time, you can certain add Teams into this. Users go into Teams, Teams go into Policies, Policies are assign to Roles which have actions that are allowed and a Project to filter what is seen.
>
> And more Hindsight, a lot of this effort in this PoC / Discovery exercise is because I wanted to limit the functionality and what is visible to the "user". If that isn't a concern and you are just using what is out of the box, then you should actually be able to get away with not doing any of the API stuffs. I'll play with this in a bit and create a Prod Project that filters on Policy Group.... After playing with it, confirmed. So using the OOB configs, you can do all you need to do via 

### json data for roles and policies

ROLE: devops-viewer

```json
{
    "name": "Devops Viewer",
    "id": "devops-viewer",
    "actions": [
        "infra:nodes:get",
        "infra:nodes:list",
        "compliance:*:get",
        "compliance:*:list"
    ],
    "projects": []
}
```

ROLE: devops-admin

```json
{
    "name": "Devops Owner",
    "id": "devops-owner",
    "actions": [
        "reportmanager:*",
        "infra:nodes:*",
        "infra:nodeManagers:*",
        "infra:infraServers:list",
        "infra:infraServers:get",
        "compliance:*",
        "event:*",
        "ingest:*",
        "secrets:*",
        "iam:projects:list",
        "iam:projects:get",
        "iam:projects:assign",
        "iam:policies:list",
        "iam:policies:get",
        "iam:policyMembers:*",
        "iam:teams:list",
        "iam:teams:get",
        "iam:teamUsers:*",
        "iam:users:get",
        "iam:users:list"
    ],
    "projects": []
}
```

POLICY: Devops IT Owner

```json
{
  "name": "Devops IT Owner",
  "id": "devops_it-project-owners",
  "projects": [
    "devops_it"
  ],
  "members": [
    "user:local:devops-it-admin"
  ],
  "statements": [
    {
      "effect": "ALLOW",
      "role": "devops-owner",
      "projects": [
        "devops_it"
      ]
    }
  ]
}
```

POLICY: Devops IT Viewer

```json
{
  "name": "DevOps IT Viewers",
  "id": "devops_it-project-viewers",
  "projects": [
    "devops_it"
  ],
  "members": [
    "user:local:devops-it-oper"
  ],
  "statements": [
    {
      "effect": "ALLOW",
      "role": "devops-viewer",
      "projects": [
        "devops_it"
      ]
    }
  ]
}
```

POLICY: Devops IT Owner

```json
{
  "name": "IT DevOps Viewers",
  "id": "it_devops-project-viewers",
  "projects": [
    "it_devops"
  ],
  "members": [
    "user:local:it-devops-admin"
  ],
  "statements": [
    {
      "effect": "ALLOW",
      "role": "devops-owner",
      "projects": [
        "it_devops"
      ]
    }
  ]
}
```

POLICY: IT Devops Viewer

```json
{
  "name": "IT DevOps Viewers",
  "id": "it_devops-project-viewers",
  "projects": [
    "it_devops"
  ],
  "members": [
    "user:local:it-devops-oper"
  ],
  "statements": [
    {
      "effect": "ALLOW",
      "role": "devops-viewer",
      "projects": [
        "it_devops"
      ]
    }
  ]
}
```

## Other cool stuff

In Postman, you can put all of your config items in and test it. When you are satisfied, click </> Code snippet on the right and you can select CURL or PowerShell Rest Method and it will generate the script. You can then use that as a base for codifying the creation / modification of the Roles and Policies. If you have a lot of Projects (because of many orgs or whatever you want to group these views one), you are going to want to put the process into some sort of automation. Also, until we get the creation and modification of these into Automate, using Postman for this might be more effort than scripting and leads to more human error. 

Here is an example of the output script for PowerShell because I am a Windows user.

```powershell
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("api-token", "iIQQcINrooXg6z6PH5pq5-e9QkA=")
$headers.Add("Content-Type", "application/json")

$body = "{
`n    `"name`": `"Devops IT Owner`",
`n    `"id`": `"devops_it-project-owners`",
`n    `"projects`": [
`n        `"devops_it`"
`n    ],
`n    `"members`": [
`n        `"user:local:devops-it-admin`"
`n    ],
`n    `"statements`": [
`n        {
`n            `"effect`": `"ALLOW`",
`n            `"role`": `"devops-owner`",
`n            `"projects`": [
`n                `"devops_it`"
`n            ]
`n        }
`n    ]
`n}"

$response = Invoke-RestMethod 'https://snohio.azure.chef-demo.com/apis/iam/v2/policies/devops_it-project-owners' -Method 'PUT' -Headers $headers -Body $body
$response | ConvertTo-Json
```

And why not bash:

```Shell - wget
wget --no-check-certificate --quiet \
  --method PUT \
  --timeout=0 \
  --header 'api-token: iIQQcINrooXg6z6PH5pq5-e9QkA=' \
  --header 'Content-Type: application/json' \
  --body-data '{
    "name": "Devops IT Owner",
    "id": "devops_it-project-owners",
    "projects": [
        "devops_it"
    ],
    "members": [
        "user:local:devops-it-admin"
    ],
    "statements": [
        {
            "effect": "ALLOW",
            "role": "devops-owner",
            "projects": [
                "devops_it"
            ]
        }
    ]
}' \
   'https://snohio.azure.chef-demo.com/apis/iam/v2/policies/devops_it-project-owners'
```

## Steps when creating a new org through automation

Chef Server:

- [ ] create the org
- [ ] add the user(s) that are going to do knife, service accounts for the pipeline, etc.

Pipeline:

- [ ] create or update the pipeline to push cookbooks / policies to

Active Directory

- [ ] Create the Admin and/or Viewer groups

Automate:

- [ ] create the Project and filter for that org
- [ ] create the Policy that points to the Role and is assigned to the Project and add the SAML/LDAP group for AD. (Or create local users and put them into Policy)

## Useful Links

[Automate Policies](https://docs.chef.io/automate/policies/)
[Automate Roles](https://docs.chef.io/automate/roles/)
[Automate API Access Management](https://docs.chef.io/automate/api/#tag/policies) (Scroll down from there for the Roles)
[Recent Chef Blog Post on Projects](https://www.chef.io/blog/group-nodes-via-projects-in-chef-automate)

## Conclusion

Wow, what to say. This was an excellent and fun PoC / Learning Exercise / Demo Prep. I know a few customers that could actually use this functionality.  I could see it getting out of hand pretty quickly, but if it gets to that point, automating the creation process is going to be a must. I <3 the flexibility that it can give you. In the demo, I had two Orgs and had a project for each, but also created a Project based on the Policy Group it is in. Granted this only impacts Visibility, but you could give auditors access to only production systems, or Developers across different orgs. There are a lot of possibilities.

At the end of the day here, I was able to solve for my use case at the top of this long thread. I hope this document has helped someone work through Automate Projects, drop me a line if it has on the [Chef Community Slack](https://community.chef.io/slack).

I want to thank Sean Horn for giving me a hand walking through the API stuffs. It had been awhile since I've done any Postman / API work.
