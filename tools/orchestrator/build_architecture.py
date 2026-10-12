#!/usr/bin/env python3
"""Generate the editable Orchestrator 2.5 application domain and lifecycle graphs.

The .torch serialization follows the official project's integration fixtures.
This file generates graph topology; application logic remains typed GDScript.
"""
from pathlib import Path
import json
import uuid

DOMAINS = {
    "profile": ["open_profiles", "create_profile", "select_profile", "rename_profile", "delete_profile"],
    "progression": ["play", "continue", "open_map", "select_biome", "open_level", "start_level", "to_map", "next", "story_done", "open_shop", "buy_item", "undo_purchase", "select_character", "toggle_perk", "select_potion", "select_item_slot"],
    "session": ["pause", "resume", "retry", "open_tools", "pick_shape", "choose_down", "flick", "undo", "reset", "move", "rotate", "drop", "soft", "hold", "use_skill", "use_item", "tap"],
    "modes": ["open_arcade", "start_arcade", "open_tournament", "start_tournament", "open_physics", "start_physics"],
    "lan": ["host_lan", "join_lan", "start_lan", "leave_lan"],
    "preferences": ["open_settings", "set_pref"],
    "presentation": ["view", "back", "quit"],
}
TRANSITIONS = {
    "boot": "idle", "profile": "profile", "map": "map", "intro": "intro",
    "session_begin": "playing", "session_countdown": "countdown",
    "session_pause": "paused", "session_resume": "playing", "session_end": "result",
    "session_clear": "idle", "party_lobby": "party", "party_round": "playing",
    "party_leave": "idle", "focus_out": "paused", "save_commit": "saved",
}


def val(v):
    if isinstance(v, bool): return "true" if v else "false"
    if v is None: return "null"
    if isinstance(v, str): return json.dumps(v)
    if isinstance(v, list): return "[" + ", ".join(val(x) for x in v) + "]"
    if isinstance(v, dict): return "{" + ", ".join(json.dumps(k) + ": " + val(x) for k, x in v.items()) + "}"
    return str(v)


class Graph:
    def __init__(self):
        self.objects = []; self.nodes = []; self.functions = []; self.graphs = []; self.edges = []; self.next_id = 0

    def obj(self, kind, name, props):
        self.objects.append(f'[obj type="{kind}" id="{name}"]\n' + "\n".join(f"{k} = {v}" for k, v in props.items()) + "\n")
        return f'SubResource("{name}")'

    def node(self, kind, pins, props=None, x=0, y=0):
        ident = self.next_id; self.next_id += 1
        ref = self.obj(kind, f"{kind}_{ident}", {**(props or {}), "id": ident, "position": f"Vector2({x}, {y})", "size": "Vector2(240, 150)", "pin_data": f"Array[Dictionary]({val(pins)})"})
        self.nodes.append(ref); return ident

    def edge(self, source, out_port, target, in_port): self.edges.extend([source, out_port, target, in_port])

    def function(self, name, parameters):
        ident = self.next_id; guid = str(uuid.uuid5(uuid.NAMESPACE_URL, "wacky-towers/architecture/"+name)).upper()
        method = {"name": name, "args": [{"name": n, "type": t} for n,t in parameters], "flags": 8}
        self.functions.append(self.obj("OScriptFunction", "Function_"+name, {"guid": val(guid), "method": val(method), "user_defined": "true", "id": ident}))
        pins = [{"pin_name": "ExecOut", "dir": 1, "flags": 4}] + [{"pin_name": n, "type": t, "dir": 1, "flags": 2} for n,t in parameters]
        entry = self.node("OScriptNodeFunctionEntry", pins, {"function_id": val(guid)}, x=0)
        return entry

    def finish_graph(self, name, first, entry):
        self.graphs.append(self.obj("OScriptGraph", "Graph_"+name, {"graph_name": val(name), "flags":22, "nodes":f"Array[int]({val(list(range(first,self.next_id)))})", "functions": f"Array[int]([{entry}])"}))

    def call(self, name, args, returns=0, x=0, y=0):
        pins=[{"pin_name":"ExecIn","flags":4}, {"pin_name":"ExecOut","dir":1,"flags":4}, {"pin_name":"target","type":24,"flags":2050,"target_class":"WtArchitecture","dv":None}]
        pins += [{"pin_name":n,"type":t,"flags":2,**({"dv":d} if d is not None else {})} for n,t,d in args]
        if returns: pins += [{"pin_name":"return_value","type":returns,"dir":1,"flags":1026}]
        method={"name":name,"args":[{"name":n,"type":t} for n,t,_ in args],"return":{"type":returns,"usage":6 if returns else 0},"flags":8}
        return self.node("OScriptNodeCallMemberFunction", pins, {"function_name":val(name),"target_class_name":val("WtArchitecture"),"target_type":24,"flags":520,"method":val(method),"chain":"false"},x,y)

    def switch(self, cases, x=800, y=0):
        pins=[{"pin_name":"ExecIn","flags":516},{"pin_name":"value","flags":2,"usage":131078}]
        pins += [{"pin_name":f"case_{i}","flags":2,"usage":131078,"dv":name} for i,name in enumerate(cases)]
        pins += [{"pin_name":"Done","dir":1,"flags":516},{"pin_name":"default","dir":1,"flags":516}]
        pins += [{"pin_name":f"case_{i}_out","dir":1,"flags":4} for i in range(len(cases))]
        return self.node("OScriptNodeSwitch",pins,{"cases":len(cases)},x,y)

    def text(self):
        return f'[orchestration type="OScript" load_steps={len(self.objects)+1} format=3]\n\n'+"\n".join(self.objects)+ '\n[resource]\nbase_type = &"Node"\nbrief_description = "Wacky Towers architecture: guarded domain dispatch and explicit application lifecycle"\n' + "\n".join(f"{k} = Array[{t}]([{', '.join(v)}])" for k,t,v in [("functions","OScriptFunction",self.functions),("nodes","OScriptNode",self.nodes),("graphs","OScriptGraph",self.graphs)]) + f"\nconnections = Array[int]({val(self.edges)})\n"


def build():
    g=Graph(); first=g.next_id; entry=g.function("dispatch",[("intent",21),("data",27),("bridge",24)])
    allow=g.call("allows",[("intent",21,None),("data",27,None)],returns=1,x=280)
    branch=g.node("OScriptNodeBranch",[{"pin_name":"ExecIn","flags":516},{"pin_name":"condition","type":1,"flags":2,"dv":False},{"pin_name":"true","dir":1,"flags":516},{"pin_name":"false","dir":1,"flags":516}],x=580)
    g.edge(entry,0,allow,0);g.edge(entry,1,allow,2);g.edge(entry,2,allow,3);g.edge(entry,3,allow,1);g.edge(allow,0,branch,0);g.edge(allow,1,branch,1)
    reject=g.call("reject",[("intent",21,None),("data",27,None)],x=1500,y=1250)
    for slot, target in [(1,2),(2,3),(3,1)]:g.edge(entry,slot,reject,target)
    g.edge(branch,1,reject,0)
    routes={}
    for index,domain in enumerate(DOMAINS):
        route=g.call("route_"+domain,[("intent",21,None),("data",27,None)],x=1500,y=index*180)
        for slot,target in [(1,2),(2,3),(3,1)]:g.edge(entry,slot,route,target)
        routes[domain]=route
    intents=[(i,d) for d,items in DOMAINS.items() for i in items]
    previous=None
    for chunk_start in range(0,len(intents),32):
        chunk=intents[chunk_start:chunk_start+32];switch=g.switch([i for i,_ in chunk],y=chunk_start*35)
        g.edge(entry,1,switch,1)
        if previous is None:g.edge(branch,0,switch,0)
        else:g.edge(previous,1,switch,0)
        for index,(_,domain) in enumerate(chunk):g.edge(switch,index+2,routes[domain],0)
        previous=switch
    g.edge(previous,1,reject,0);g.finish_graph("ApplicationDomains",first,entry)
    first=g.next_id;entry=g.function("transition",[("event",21),("data",27),("bridge",24)])
    switch=g.switch(list(TRANSITIONS),x=400);g.edge(entry,0,switch,0);g.edge(entry,1,switch,1)
    for index,(event,state) in enumerate(TRANSITIONS.items()):
        node=g.call("apply_transition",[("state",21,state),("event",21,None),("data",27,None)],x=900,y=index*160)
        g.edge(switch,index+2,node,0);g.edge(entry,3,node,1);g.edge(entry,1,node,3);g.edge(entry,2,node,4)
    g.finish_graph("ApplicationLifecycle",first,entry)
    return g.text()


if __name__ == "__main__":
    import argparse
    parser=argparse.ArgumentParser();parser.add_argument("--output",type=Path,required=True);args=parser.parse_args();args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(build())
