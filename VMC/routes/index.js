var express = require('express');
var path = require('path');
var fs = require('fs');

var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  //res.render('index', { title: 'Express' });
  fs.readFile(path.join(__dirname, "catagory.json"), function (err, data) {
    if (err) {
      console.log(err);
      res.end(err.toString());
      return;
    }
    console.log(data);

    function sleep(milliSeconds) {
      var startTime = new Date().getTime();
      while (new Date().getTime() < startTime + milliSeconds);
    };
    sleep(500);

    res.header("Content-Type", "application/json; charset=utf-8");
    res.end(data);
  });
});

module.exports = router;
