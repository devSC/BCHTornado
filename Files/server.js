const url = require('url');
const http = require('http');

const hostname = '0.0.0.0';
const port = 3000;

var peoples = []; 

const server = http.createServer((req, res) => {

    res.statusCode = 200;
    res.setHeader('Content-Type', 'application/json');
    var q = url.parse(req.url, true);
    var response = {"result":"hello world!"};

    if( q.pathname == '/group' ) {
        response.result = "1";
    }

    if( q.pathname == '/group/join' ) {

        for(var i=0;i<peoples.length;i++){
            if( peoples[i].address == q.query.address ) {
                response.result = "address already exists";
                response = JSON.stringify(response);
                res.end(response);
                return ;
            }
        }

        peoples.push(q.query);
        response.result = "ok";
    }

    if( q.pathname == '/group/people' ) {
        response.result = peoples;
    }

    if( q.pathname == '/group/quit' ) {
        
        for(var i=0;i<peoples.length;i++){
            if( peoples[i].address == q.query.address ) {
                 peoples.splice(i, 1);
            }
        }

        response.result = "ok";
    }

    response = JSON.stringify(response);
    res.end(response);
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});
