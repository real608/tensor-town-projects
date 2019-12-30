//
// $Id$

package {

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.EntityControl;

/**
 * Creates and registers listeners to manage LandSeaAnimal duels
 */
public class DuelingLandSeaAnimal
{
    protected const VERSION:Number = 2.0;
    

    /**
     * 
     *
     * @param ctrl the avatar control
     * @param duelState the name of the state that dueling takes place in, this can be a string, or an array of strings
     * @param duelAction the name of the action that fires the weapon, this can be a string, or an array of strings
     * @param deadState the name of the state that kills the avatar, this can be a string, or an array of strings.  
     *                  If an array of strings is provided, one state at random is chosen on death
     */
    public function DuelingLandSeaAnimal (ctrl :AvatarControl, duelState:Object, duelAction:Object, deadState:Object)
    {
        _ctrl = ctrl;
        if (duelState is String) {
            _duelStates = [duelState];
        } else {
            _duelStates = duelState as Array;
        }
        
        if (duelAction is String) {
            _duelActions = [duelAction];
        } else {
            _duelActions = duelAction as Array;
        }
        
        if (deadState is String) {
            _deadStates = [deadState];
        } else {
            _deadStates = deadState as Array;
        } 
        
        myId = _ctrl.getMyEntityId();
        
        _ctrl.addEventListener(ControlEvent.SIGNAL_RECEIVED, handleSignal);
        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED,  actionTriggered);
        _ctrl.registerPropertyProvider(propertyProvider);
    }
    
    protected function actionTriggered(event:ControlEvent) {       
	
        // If the action being used is in or _duelActions array, and we are currently in the duel state  -- ATTAX!
        if (_duelActions.indexOf(event.name) != -1 
                && _ctrl.getEntityProperty("landseaanimal:inDuelState", myId)) {
            // The following signal is being deprecated, you are the weakest link, goodbye
            //_ctrl.sendSignal("sendSignal", {note:"Die", id:myId});
            
            var orient :Number = _ctrl.getOrientation();

            var myPos :Array = _ctrl.getEntityProperty(EntityControl.PROP_LOCATION_PIXEL, myId) as Array;
            var theirPos: Array;
            var aminal:Object = new Object();
            var avis :Array = _ctrl.getEntityIds(EntityControl.TYPE_AVATAR);
                        
            for each (var id :String in avis) {
                if (id != myId && _ctrl.getEntityProperty("landseaanimal:inDuelState", id)) {
                    theirPos = _ctrl.getEntityProperty(EntityControl.PROP_LOCATION_PIXEL, id) as Array;
                    
                    var posDifference:Array = new Array(myPos[0] - theirPos[0], 
                        myPos[1] - theirPos[1], 
                        myPos[2] - theirPos[2]);
                    
                    // Pythagoras Theorem FTW!
                    var distance:Number = Math.sqrt(Math.pow(posDifference[0], 2) + 
                        Math.pow(posDifference[1], 2));
                    
                    if (posDifference[0] > 0 && orient > 180) {
                        if (!aminal.distance || aminal.distance > distance) {
                            aminal.id = id;
                            aminal.distance = distance;
                        }
                    } else if (posDifference[0] <= 0 && orient <= 180) {
                        if (!aminal.distance || aminal.distance > distance) {
                            aminal.id = id;
                            aminal.distance = distance;
                        }
                    }
                                        
                }
            }
            
            if (aminal.id) {
                _ctrl.getEntityProperty("landseaanimal:IKillJoo", 
                    aminal.id);
                
                // We are checking for control here so every single instance doesn't send a signal.
                // This signal is meant so someone can make a third party furni or pet who keeps track of battles.
                if (_ctrl.hasControl()) {
                    _ctrl.sendSignal("lsa:deathNotice", {killer:myId, killee:aminal.id});
                }
            }
            
            
        }

    }
    
    function handleSignal (event :ControlEvent) :void
    {	
        /* This method has been deprecated, nothing to see here, move along.
        
        var entityId :String = event.name;
        var myCurrentState :String = _ctrl.getState();

        if (myCurrentState == _duelStates[0] && 
                !_ctrl.getEntityProperty("landseaanimal:UIsOne?", event.value.id)){
            if (event.value.note == "Die" && event.value.id != myId) {
                _ctrl.setState(_deadStates[0]);
            }
            
		            
        }
        */
    }

    function propertyProvider (key :String) :Object
    {
        switch (key) {
            case "landseaanimal:UIsOne?":
                return VERSION;
                break;
            case "landseaanimal:inDuelState":
                // Here we are checking if our current state is in the array of valid duel states
                return (_duelStates.indexOf(_ctrl.getState()) != -1);
                break;
            case "landseaanimal:IKillJoo":
                //Are we in a duel state?
                if (_ctrl.getEntityProperty("landseaanimal:inDuelState", myId)) {
                    // Lets pick a rancom death state from our death state array            
                    var aDeathState:String = _deadStates[Math.floor(Math.random() * (_deadStates.length - 1))];
                    _ctrl.setState(aDeathState);

                }
                break;
        }
        return null;
    }
    
    
    protected var _ctrl:AvatarControl;
    protected var _duelStates:Array;
    protected var _duelActions:Array;
    protected var _deadStates:Array;
    protected var myId :String;

}
}
