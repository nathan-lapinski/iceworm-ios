/*
Date: 10/9/15
This function is used for sending directed push notifications
to the users in the "from" dictionary (dictionary). "From" is
a dictionary which also containts account type so we can 
accommodate various types of login accounts in the future
*/
Parse.Cloud.define("sendNewQuestionPushes",function(request,response){
	
	var toUsers = new Parse.Query(Parse.User);
	var pushQuery = new Parse.Query(Parse.Installation);
	
	//Here, sepearte account types and address as needed
	var array_keys = new Array();
	//var array_values = new Array();
	
	for (var key in request.params.to) {
		array_keys.push(key);
    	//array_values.push(request.params.to[key]);
	}
	
	toUsers.containedIn("facebookId",array_keys);
	pushQuery.matchesQuery("user",toUsers);
	
	var displayString = "New Q from " + request.params.from
	
	Parse.Push.send({
		where: pushQuery,
		data: {
			alert: displayString
		}
	},{
		success: function() {
			response.success(array_keys)
		},
		error: function(error) {
			response.error("Shit got fucked up, yo!")
		}
	});
});


/*
Date: 8/9/15
This function is used for retrieving all user accounts whose 
username field contains the string specified in request.params.userString.
The response is an array of username strings.
Android devs can pull this into an ArrayList<String>
Ios devs can pull this into an ...?
*/
Parse.Cloud.define("searchForUser",function(request,response){
	//get the substring to search for
	var sSubStr = request.params.userString;
	var sCurrentUser = request.params.currentUser;
	//Launch the query over the users table
	var query = new Parse.Query("User");
	query.notEqualTo("username",sCurrentUser);
	query.contains("username",sSubStr);
	query.find({
		success: function(results){
			var names = [];
			for(var i = 0; i < results.length; i++){
				names.push(results[i].get("username"));
			}
			response.success(names);
		},
		error: function(){
			response.error("Error looking up this user name");
		}
	})

});

/*
Date: 8/10/15
This function is used for searching for new users to add as friends.
If there is a direct match, the weight field will be "0"
otherwise, we provide a weight based on the edit-distance algorithm
Lower weights are better matches.

*/
Parse.Cloud.define("findNewUser",function(request,response){
	//get the substring to search for
	var sSubStr = request.params.userString;
	var sCurrentUser = request.params.currentUser;
	//test this check
	if(sSubStr == undefined){
		return {};
	}
	//Launch the query over the users table
	var query = new Parse.Query("User");
	query.notEqualTo("username",sCurrentUser);
	query.equalTo("username",sSubStr);
	query.find({
		success: function(results){
			var names = [];
			for(var i = 0; i < results.length; i++){
				var curr_usr = {
					"userObject": results[i],
					//"username": results[i].get("username"),
					//"name": results[i].get("name"),
					"weight": "0"
				};
				names.push(curr_usr);
			}
			if(results.length == 0){
				//We failed to find an exact match, so let's see if 
				//we can make some suggestions
				console.log("in1deep")
				var suggestQuery = new Parse.Query("User");
				suggestQuery.notEqualTo("username",sCurrentUser);
				suggestQuery.contains("username",sSubStr);
				suggestQuery.find({
					success: function(res){
						console.log("in2deep");
						for(var i = 0; i < res.length; i++){
							var w = String(editDistance(sSubStr,res[i].get("username")));
							var curr_usr = {
								"userObject": res[i],
								//"username": res[i].get("username"),
								//"name": res[i].get("name"),
								"weight": w
							};
							names.push(curr_usr);
						}
						console.log("Found: ",names.length);
						//sort it vai Array.prototype.sort and send it down
						names.sort(function(a,b){
							if(a.weight < b.weight) return 1;
							if(a.weight > b.weight) return -1;
							return 0;
						});
						response.success(names);
					},//end handler
					error: function(){
						res.error("Error attempting to find suggestions");
					}

				});

			} else {
			response.success(names);
			}
			
		},
		error: function(){
			response.error("Error looking up this user name");
		}
	})

});

//Used in calculating weights in the findNewUser function suggestions
function editDistance(a, b){
  if(a.length == 0) return b.length; 
  if(b.length == 0) return a.length; 

  var matrix = [];

  // increment along the first column of each row
  var i;
  for(i = 0; i <= b.length; i++){
    matrix[i] = [i];
  }

  // increment each column in the first row
  var j;
  for(j = 0; j <= a.length; j++){
    matrix[0][j] = j;
  }

  // Fill in the rest of the matrix
  for(i = 1; i <= b.length; i++){
    for(j = 1; j <= a.length; j++){
      if(b.charAt(i-1) == a.charAt(j-1)){
        matrix[i][j] = matrix[i-1][j-1];
      } else {
        matrix[i][j] = Math.min(matrix[i-1][j-1] + 1, // substitution
                                Math.min(matrix[i][j-1] + 1, // insertion
                                         matrix[i-1][j] + 1)); // deletion
      }
    }
  }

  return matrix[b.length][a.length];
};

/*
8/18/15
This is used for adding groupies to the QJoin table
//input: an array of groupies usernames [grp1, grp2,...,grpn ]
//1.queue question for non-app fb users (for when they sign up, give them the question. limit this via timestamp and #)
//2.fb notifications.  https://developers.facebook.com/docs/app-invites/android
*/
Parse.Cloud.define("askToGroupies",function(request,response){
	var oQObj = request.params.wrapperObject.question;
	var oUsr = request.params.wrapperObject.user;
	var aGroupies = request.params.wrapperObject.groupies;

	//let's write this shit to the db
	for(var i = 0; i < aGroupies.length; i++){
		var qJoin = Parse.Object.extend("qJoin");
		var q = new qJoin();
		q.set("question",oQObj);
		q.set("from",oUsr);
		q.set("to",aGroupies[i]);
		q.set("asker",oUsr);
		q.save(null,{
			success: function(){
				console.log("Got it");
			},
			error: function(){
				console.log("something is effed in the A");
			}
		});
	}
});


/*
Date: 8/11/15

*/
/*
Parse.Cloud.define("askQuestion",function(request,response){
	//get the question params
	var SocialQ = Parse.Object.extend("SocialQs");
	var socialq  = new SocialQ();

	socialq.set("question",request.params.question);
	socialq.set("option1",request.params.option1);
	socialq.set("option2",request.params.option2);
	socialq.set("stats1",request.params.stats1);
	socialq.set("stats2",request.params.stats2);
	socialq.set("askername",request.params.askername);
	socialq.set("askedId",request.params.askerId);
	if(request.params.questionPhoto){
		socialq.set("questionPhoto",request.params.questionPhoto);
	}
	if(request.params.option1Photo){
		socialq.set("option1Photo",request.params.option1Photo);
	}
	if(request.params.option2Photo){
		socialq.set("option2Photo",request.params.option2Photo);
	}

	//Save this data to SocialQs, and update Votes and UserQs
	socialq.save(null,{
		success: function(sq){
			var Vote = Parse.Object.extend("Votes");
			var vote = new Vote();
			vote.save(null,{
				success:function(v){
					socialq.set("votesId",v.id);
					socialq.save(null,{s:function(){},e:function(){}});
				},
				error:function(v,e){

				}
			});//end vote callback
			//Let's also go ahead and update userQs
			/*var UserQ = Parse.Object.extend("UserQs");
			var userq = new UserQ();

			userq.save(null,{
				success:function(uq){

				},
				error:function(uq,e){

				}
			});//end userq callback
			response.success("we made something from nothing");
		},
		error: function(socialq,error){

		}
	});//end socialq save
});

Parse.Cloud.define("assignToSocialQsGroupies",function(request,response){
	//get the array of users to search for
	var aGroups = request.params.socialQsGroupies;
	//Launch the query over the users table
	var query = new Parse.Query("User");
	query.notEqualTo("username",sCurrentUser);
	query.contains("username",sSubStr);
	query.find({
		success: function(results){
			var names = [];
			for(var i = 0; i < results.length; i++){
				names.push(results[i].get("username"));
			}
			response.success(names);
		},
		error: function(){
			response.error("Error looking up this user name");
		}
	})

});
*/