// CArtAgO artifact code for project smadasMAPC2013

package artifacts;

import cartago.*;

public class Strategy extends Artifact {
	
	//numero estrategia
	//round
	//informacoes a respeito dos agentes, prioridade, etc
	
	void init(int initialValue) {
		defineObsProperty("count", initialValue);
	}
	
	@OPERATION
	void inc() {
		ObsProperty prop = getObsProperty("count");
		prop.updateValue(prop.intValue()+1);
		signal("tick");
	}
}

