;                                                                                                                                                         
;                                                          ^                                                                                                  
;              +---------+   +---------+                 /   \                                                                                                          
;              | product |   | counter |---------------><  <  >                                                                                                            
;              +---------+   +---------+                 \   /                                                                                                          
;                ^  |            |  | |                    v                                                                                         
;                |  |            |  | |                    ^                                                                                         
;                |  +-----+   +--+  | +-------------+      |                                                                                    
;                |        |   |     |        ^      |      |                                                                                    
;                |        |   |     |       / \     |      ^                                                                                           
;                _        |   |     +-+    / 1 \    |     / \                                                                                          
;   product<-t1 |x|       |   |       |   +-----+   |    / n \                                                                                         
;                |        |   |       |      |      |   +-----+                                                                                        
;                |        |   |       |      |      _                                                                                     
;                |        |   |       |   +--+     |x|  counter<-t2                                                                                       
;                |        v   v       v   v         |                                                                                           
;              +--+    +---------+  +-------+      +--+                                                                                           
;              |t1|     \   *   /    \  +  /       |t2|                                                                                           
;              +--+      +-----+      +---+        +--+                                                                                           
;                ^          |           |           |                                                                                           
;                |    _     |           |    _      |                                                                                           
;                +---|x|----+           +---|x|-----+                                                                                           
;                                                                                                                                                          
;                t1<-product       counter<-counter                                                                                                       
;                                                                                                                                                          
;                                                                                                                                                          
;                                                                                                                                                          
;               done                                                                                                                                    
;                ^                                                                                                                                     
;                |                                                                                                                                     
;                ^          +-------------+     +-------------+     +-------------+     +-------------+                                                                                           
;   start----->< > >------->| t1<-product |---->| product<-t1 |---->| t2<-counter |---->| counter<-t2 |                                                                                           
;                v          +-------------+     +-------------+     +-------------+     +-------------+                                                                                           
;                ^                                                                              |                                                                           
;                |                                                                              |                                                                           
;                +------------------------------------------------------------------------------+                                                                           
;                                                                                                                                                  