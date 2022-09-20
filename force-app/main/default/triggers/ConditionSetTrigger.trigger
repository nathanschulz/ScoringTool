trigger ConditionSetTrigger on Condition_Set__c (before insert, before update) {

	//NATHAN TODO: make sure validations happen in the front-end
	List<String> getRPNTokens(List<String> tokens, Integer maximumValidNumber) {
		List<String> rpnTokens = new List<String>();
		List<String> operatorStack = new List<String>();
      
		for (String currentToken : tokens) {
			if (currentToken == 'AND' || currentToken == 'OR') {
				while (!operatorStack.isEmpty()) {
					String nextToken = operatorStack.get(operatorStack.size() - 1);
					if (nextToken == 'AND' || nextToken == 'OR') {
						rpnTokens.add(operatorStack.remove(operatorStack.size() - 1));
					} else {
						break;
					}
				}
				operatorStack.add(currentToken);
			} else if (currentToken == '(') {
				operatorStack.add(currentToken);
			} else if (currentToken == ')') {
				Boolean matchFound = false;
				while (!operatorStack.isEmpty() && !matchFound) {
					String nextToken = operatorStack.remove(operatorStack.size() - 1);
					if (nextToken == '(') {
						matchFound = true;
					} else {
						rpnTokens.add(nextToken);
					}
				}
				// if (!matchfound && operatorStack.isEmpty()) {
				// 	throw new IllegalArgumentException('Logical Statement Contains Mismatched Parentheses.');
				// }
			} else if (currentToken.isNumeric()) {
				Integer lineItemIndex = Integer.valueOf(currentToken);
				// if (maximumValidNumber < lineItemIndex) {
				// 	throw new IllegalArgumentException('No such condition: ' + currentToken);
				// } else if (lineItemIndex < 1) {
				// 	throw new IllegalArgumentException('No such condition: ' + currentToken);
				// }
				rpnTokens.add(currentToken);
			} else {
				// throw new IllegalArgumentException('Logical Statement Contains Illegal Token: ' + currentToken);
			}
		}
		
		while (!operatorStack.isEmpty()) {
			String poppedToken = operatorStack.remove(operatorStack.size() - 1);
			if (poppedToken == ')' || poppedToken == '(') {
				throw new IllegalArgumentException('Logical Statement Contains Mismatched Parentheses.');
			} else {
				rpnTokens.add(poppedToken);
			}
		}
		return rpnTokens;
	}

	// void checkTokenSequence(String logicalStatement) {
 //      //we either expect an open parentheses/integer  or an operator/closed parentheses
 //    	Boolean expectingOpenParenthesesOrInteger = true;
 //    	for (String token : logicalStatement.split(' ')) {
	// 		if (expectingOpenParenthesesOrInteger && (token == 'AND' || token == 'OR' || token == ')')) {
	// 			throw new IllegalArgumentException('Bad Syntax');
	// 		} else if (!expectingOpenParenthesesOrInteger && (token == '(' || token.isNumeric())) {
	// 			throw new IllegalArgumentException('Bad Syntax');
	// 		}
	// 		if (token == 'AND' || token == 'OR') {
	// 			expectingOpenParenthesesOrInteger = true;
	// 		} else if (token == ')' || token.isNumeric()) {
	// 			expectingOpenParenthesesOrInteger = false;
	// 		} 
	// 	}
 //    }

	void convertLogicForm(Condition_Set__c cs) {
    	String logicalStatement = cs.Logical_Statement__c;
    	logicalStatement = logicalStatement.replaceAll('\\(',' ( ');
    	logicalStatement = logicalStatement.replaceAll('\\)', ' ) ');
    	logicalStatement = logicalStatement.replaceAll('\\s+',' ');
    	logicalStatement = logicalStatement.trim();
    	List<Condition_Line_Item__c> clis = [SELECT Id FROM Condition_Line_Item__c WHERE Condition_Set__c = :cs.Id];
   		// checkTokenSequence(logicalStatement);
    	List<String> rpnTokens = getRPNTokens(logicalStatement.split(' '), clis.size());
    	cs.RPN_Logic__c = String.join(rpnTokens,',');
	}



	for (Condition_Set__c cs : Trigger.new) {
		if (cs.Skip_Validation__c == true) { 
			cs.Skip_Validation__c = false;
			continue;
		}
		if (!String.isEmpty(cs.Logical_Statement__c) && (Trigger.isInsert || cs.Logical_Statement__c != Trigger.oldMap.get(cs.Id).Logical_Statement__c)) {
			convertLogicForm(cs);
		}
	}
}