'use strict';

const gitlab = require('gitlab')({
  url:   'http://localhost:10080',
  token: 'WsfnfRfs1KF7axq_2ysk'
});

// Listing users
// gitlab.users.all((users) => {
//     users.forEach((user) => {
//         console.log(user);
//     });
// });

const owner = 'k1low';
const repo = 'my-faultline-gitlab-project';
const errorMessage = '[ReferenceError] Can\'t find variable: ga';
gitlab.projects.all((projects) => {
    let project = projects.find((project) => {
        return (project.path_with_namespace == `${owner}/${repo}`);
    });
    gitlab.projects.issues.list(project.id, {
        search: errorMessage,
        per_page: 10
    }, (issues) => {
        let issue = issues.find((issue) => {
            return (issue.title == errorMessage);
        });
        if (issue) {
            // reopen issue
            console.log('reopen:' + issue.id);
            gitlab.issues.edit(project.id, issue.id, {
                state_event: 'reopen'
            });
            gitlab.notes.create(project.id, issue.id, {
                body: 'this is comment'
            });
        } else {
            // create issue
            gitlab.issues.create(project.id, {
                title: errorMessage,
                description: 'this is test',
                labels: 'bug,error'
            });
        }
    });
});


