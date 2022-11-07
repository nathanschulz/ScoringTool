public with sharing class ConditionUtility {
    //OPERATORS
    public static final String EQUALS_EXACT = '=';
    public static final String NOT_EQUALS = '!=';
    public static final String GREATER_THAN = '>';
    public static final String LESS_THAN = '<';
    public static final String GREATER_THAN_EQUALS = '>=';
    public static final String LESS_THAN_EQUALS = '<=';
    public static final String STARTS_WITH = 'startsWith';
    public static final String DOES_NOT_START_WITH = 'doesNotStartWith';
    public static final String CONTAINS = 'contains';
    public static final String DOES_NOT_CONTAIN = 'doesNotContain';
    public static final String IN_LIST = 'IN';
    public static final String IS_NULL = 'isNull';
    public static final String IS_NOT_NULL = 'isNotNull';

    //Field Types
    public static final Set<String> NUMBER_TYPES = new Set<String> { 'INTEGER', 'DOUBLE', 'CURRENCY', 'LONG', 'PERCENT' };
    public static final Set<String> STRING_TYPES = new Set<String> { 'STRING', 'EMAIL' , 'URL', 'ADDRESS', 'PHONE', 'MULTIPICKLIST', 'TEXTAREA', 'REFERENCE', 'PICKLIST' };


    public static Object getSObjectValue(SObject obj, String attr) {
        if (obj == null) return null;
        List<String> splits = attr.split('\\.');
        for(Integer i=0;i<splits.size()-1;i++) {
          obj = obj.getSObject(splits[i]);
          if(obj == null) return null;
        }
        return obj.get(splits[splits.size()-1]);
    }

    public static Boolean objectMeetsCondition(SObject s, Condition_Line_Item__c cli) {
        Object value = getSObjectValue(s,cli.Field__c);
        Object operand = cli.Operand__c;
        String operator = cli.Operator__c;
        System.debug(value);
        System.debug(operand);
        String fieldType = cli.Field_Type__c;
        
        if (fieldType == 'BOOLEAN') {
            Boolean valueBoolean = value != null ? Boolean.valueOf(value) : false;
            Boolean operandBoolean = Boolean.valueOf(operand);
            if (operator == EQUALS_EXACT) {
                return valueBoolean == operandBoolean;
            } else if (operator == NOT_EQUALS) {
                return valueBoolean != operandBoolean;
            }
        } else if (STRING_TYPES.contains(fieldType)) {
            String valueString = (String) value;
            String operandString = String.valueOf(operand);
            if (operator == EQUALS_EXACT) {
                return valueString == operandString;
            } else if (operator == NOT_EQUALS) {
                return valueString != operandString;
            } else if (operator == GREATER_THAN) {
                return valueString > operandString;
            } else if (operator == LESS_THAN) {
                return valueString < operandString;
            } else if (operator == GREATER_THAN_EQUALS) {
                return valueString >= operandString;
            } else if (operator == LESS_THAN_EQUALS) {
                return valueString <= operandString;
            } else if (operator == STARTS_WITH) {
                if (String.isEmpty(valueString)) return false;
                return valueString.startsWith(operandString);
            } else if (operator == CONTAINS) {
                if (String.isEmpty(valueString)) return false;
                return valueString.contains(operandString);
            } else if (operator == IN_LIST) {
                return (operandString.split(',')).contains(valueString);
            } else if (operator == DOES_NOT_START_WITH) {
                if (String.isEmpty(valueString)) return true;
                return !(valueString.startsWith(operandString));
            } else if (operator == DOES_NOT_CONTAIN) {
                if (String.isEmpty(valueString)) return true;
                return !valueString.contains(operandString);
            } 
        } else if (NUMBER_TYPES.contains(fieldType)) {
            Double valueDouble = Double.valueOf(value);
            Double operandDouble = Double.valueOf(operand);
            if (operator == EQUALS_EXACT) {
            } else if (operator == NOT_EQUALS) {
                return valueDouble != operandDouble;
            } else if (operator == GREATER_THAN) {
                return valueDouble > operandDouble;
            } else if (operator == LESS_THAN) {
                return valueDouble < operandDouble;
            } else if (operator == GREATER_THAN_EQUALS) {
                return valueDouble >= operandDouble;
            } else if (operator == LESS_THAN_EQUALS) {
                return valueDouble <= operandDouble;
            }
//NATHAN TODO: DATETIME
        // } else if (fieldType == 'DATETIME' || fieldType == 'DATE') {
        //     //
        //     Date operandDate = Date.valueOf(operand);
        //     DateTime valueDateTime = (DateTime) value;
        //     if (operator == '=') {
        //     } else if (operator == NOT_EQUALS) {
        //         return valueDateTime != operandDate;
        //     } else if (operator == GREATER_THAN) {
        //         return valueDateTime > operandDate;
        //     } else if (operator == LESS_THAN) {
        //         return valueDateTime < operandDate;
        //     } else if (operator == GREATER_THAN_EQUALS) {
        //         return valueDateTime >= operandDate;
        //     } else if (operator == LESS_THAN_EQUALS) {
        //         return valueDateTime <= operandDate;
        //     } else if (operator == IN_LIST) {
        //         // return ((Set<String>) operand).contains((String) value);
        //     }
        } else {

        }


        if (operator == IS_NULL) {
            Boolean valueBoolean = Boolean.valueOf(operand);
            if (valueBoolean == true) {
                return value == null;
            } else {
                return value != null;
            }
        } else if (operator == IS_NOT_NULL) {
            return value != null;
        }
        return false;
    }

    public static Boolean applyRPNLogic(List<Boolean> conditionValues, List<Object> rpnLogic) {
        Boolean currentValue;
        List<Boolean> stack = new List<Boolean>();
        for (Object token : rpnLogic) {
            Boolean computedValue;
            if (token == 'AND') {
                Boolean a = stack.remove(0);
                Boolean b = stack.remove(0);
                computedValue = a && b;
            } else if (token == 'OR') {
                Boolean a = stack.remove(0);
                Boolean b = stack.remove(0);
                computedValue = a || b;
            } else {
                computedValue = conditionValues.get(Integer.valueOf(token) - 1);
            }

            if (stack.isEmpty()) {
                stack.add(computedValue);
            } else {
                stack.add(0, computedValue);
            }
        }

        return stack.get(0);
    }


    public static Boolean objectMeetsConditionSet(SObject s, Condition_Set__c c) {
        List<Boolean> conditionOutcomes = new List<Boolean>();
        for (Condition_Line_Item__c cli : c.Condition_Set_Line_Items__r) {
            conditionOutcomes.add(objectMeetsCondition(s,cli));
        }
        System.debug(conditionOutcomes);
        return applyRPNLogic(conditionOutcomes, c.RPN_Logic__c.split(','));
    }
}
