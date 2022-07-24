public with sharing class parentObjectTriggerHelper {
    
    public static void calculateAmountOnChild(List<ParentObject__c> parentObjList1, Map<id,ParentObject__c> parentObjOldMap ) {
        Map<Id,Double> amountOnParentMap = new Map<Id,Double>();
        for(ParentObject__c p : parentObjList1){
            if(p.Amount__c != parentObjOldMap.get(p.id).Amount__c){
                System.debug('Amount on parent is changed');
                amountOnParentMap.put(p.Id,p.Amount__c);
            }
        }

        if(!amountOnParentMap.isEmpty()){
            
            Map<Id,Double> avgAmountPerParentMap = new Map<Id,Double>();
            List<ChildObject__c> childObjectlist = new List<ChildObject__c>();
            AggregateResult[] arResultList = [SELECT ParentObject__r.Id parentId, COUNT(Id) childNumbers FROM ChildObject__c WHERE ParentObject__r.Id IN :amountOnParentMap.keySet() GROUP BY ParentObject__r.Id];
            //get the child records count and store in a Map
            for(AggregateResult ar : arResultList){
                System.debug('parent id :'+ ar.get('parentId'));
                Id parentObjId = (Id) ar.get('parentId');
                Double amountOnParent = amountOnParentMap.get(parentObjId);
                System.debug('amountOnParent :'+ amountOnParent);
                Integer noOfChild = (Integer) ar.get('childNumbers');
                System.debug('noOfChild :'+ noOfChild);
                Double avgAmount = amountOnParent/noOfChild;
                System.debug('avgAmount :'+ avgAmount);
                avgAmountPerParentMap.put(parentObjId,avgAmount);
            }

            //populate amount on child records
            for(ChildObject__c c : [SELECT Id, Amount__c,ParentObject__r.Id FROM ChildObject__c WHERE ParentObject__r.Id IN :amountOnParentMap.keySet()]){
                c.Amount__c = avgAmountPerParentMap.get(c.ParentObject__r.Id);
                childObjectlist.add(c);
            }

            //update child records
            System.debug('childObjectlist :'+ childObjectlist);
            if(!childObjectlist.isEmpty()){
                update childObjectlist;
            }
        }
    }
}
