;                                                                       
;                                                          ^            
;                                                        /   \  done    
;                      +-------------------------------><  <  >------>  
;                      |                                 \   /          
;                      |                                   v            
;                      |                                   ^            
;                      |                                   |            
;       +----+  +------|---------+                         ^            
;       |    |  |      |         |                        / \           
;       |    v  v      |         |         +--------+    /   \          
;       |  +-------+   |         |         |        |   /10^-3\         
;       |   \  -  /    |         |         v        |  +------ +        
;       |    +---+     |         |   +----------+   |                   
;       |      |       |         |    \ square /    |                   
;       |      v       |         |     +------+     |                    
;       |      _     +--+      +--+     _  |        |                        
;       |     |x|--->|r2|      |r1|<---|x|-+        |                        
;       |            +--+      +--+                 |                        
;       |     r2<-r1                 r1<-guess      |                     
;       |                                           |                     
;       |      +-----+   +----+                 +-------+                 
;       |      |     |   |     \----------------| guess |<--+             
;       ^      |     v   v                      +-------+   |           
;      / \     |   +-------+  +-----+   +----+      |       |           
;     / x \    |    \  /  /   |     |   |     \-----+       |           
;    +-----+   |     +---+    |     v   v                   |           
;       |      |       |      |   +-------+                 |           
;       +------+       _      |    \  +  /                  |                   
;                     |x|     |     +---+                   |                   
;          t1<-guess   |      |       |                     |           
;                      v      |       _                     |           
;                    +----+   |      |x|  t2<-t1            |           
;                    | t1 |   |       |                     |           
;                    +----+   |       v                     |           
;                      |      |     +----+        _         |           
;                      +------+     | t2 |-------|x|--------+           
;                                   +----+                              
;                                                guess<-t2
;           done                                                        
;             ^                                                         
;         yes |                                                         
;             |                                                         
;           +---+  no   +-----------+   +--------+   +-----------+   +--------+   +-----------+
;   start-->| < |------>| t1<-guess |-->| t2<-t1 |-->| r1<-guess |-->| r1<-r2 |-->| guess<-r2 |       
;           +---+       +-----------+   +--------+   +-----------+   +--------+   +-----------+
;             ^                                                                        |
;             |                                                                        |
;             +------------------------------------------------------------------------+
;                                                                       

(controller
 test-good-enough?
   (test (op <) (reg r2) (constant 0.001))
   (branch (label sqrt-done))
   (assign t1 (op /) (constant x) (reg guess))
   (assign t2 (op +) (reg t1) (reg guess))
   (assign guess (reg t2))
   (assign r1 (op square) (reg guess))
   (assign r2 (op -) (reg r1) (constant x))
   (goto (label test-good-enough?))
 sqrt-done)
