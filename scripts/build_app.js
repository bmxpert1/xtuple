#!/usr/bin/env node

/*jshint node:true, indent:2, curly:false, eqeqeq:true, immed:true, latedef:true, newcap:true, noarg:true,
regexp:true, undef:true, strict:true, trailing:true, white:true */
/*global X:true, Backbone:true, _:true, XM:true, XT:true*/

//
// This file really just parses the arguments, and sends the real work
// off to scripts/lib/build_all.js.
//

(function () {
  "use strict";

  var program = require('commander'),
    build = require("./lib/build_all").build;

  program
    .option('-b, --backup [/path/to/the.backup]', 'Location of database backup file. Must be used with the -i flag.')
    .option('-c, --config [/path/to/alternate_config.js]', 'Location of datasource config file. [config.js]')
    .option('-d, --database [database name]', 'Use specific database. [All databases in config file.]')
    .option('-e, --extension [/path/to/extension]', 'Extension to build. [Core plus all extensions registered for the database.]')
    .option('-i, --initialize', 'Initialize database. Must be used with the -b flag.')
    .option('-k, --keepsql', 'Do not delete the temporary sql files that represent the payload of the build.')
    .option('-q, --querydirect', 'Query the database directly, without delegating to psql.')
    .option('-u, --unregister', 'Unregister an extension.')
    .option('-w, --wipeviews', 'Drop the views and the orm registrations pre-emptively.')
    .option('-y, --clientonly', 'Only rebuild the client.')
    .option('-z, --databaseonly', 'Only rebuild the database.')
    .parse(process.argv);

  build({
    backup: program.backup,
    config: program.config,
    database: program.database,
    extension: program.extension,
    initialize: program.initialize,
    keepSql: program.keepsql,
    queryDirect: program.querydirect,
    unregister: program.unregister,
    wipeViews: program.wipeviews,
    clientOnly: program.clientonly,
    databaseOnly: program.databaseonly
  }, function (err, res) {
    console.log(err || res || "Success!");
    process.exit(err ? 1 : 0);
  });

}());
