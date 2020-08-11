//////////////////////////////SETS & RANGES/////////////////////////////////////////////////////
// the reguired values are exported from the .dat file

int numberOfOrders = ...;
int numberOfBatches = ...;
int numberOfVehicles = ...;
int numberOfProductionLines = ...;
int numberOfTemperatures = ...;    

// we need to specify the ranges that we are going to use.
range Orders = 1..(numberOfOrders+2);      // customer orders + starting depot (1) + ending depot  
 
range Batches = 1..numberOfBatches;   
range Vehicles = 1..numberOfVehicles;        
range ProductionLines = 1..numberOfProductionLines;  
range Temperatures = 1..numberOfTemperatures;      // there is no a set indicated Temperature in the table
                 

/////////////////////////////////PARAMETERS////////////////////////////////////////////////////
                                             
int W_1 = ...;
int W_2 = ...;
int W_3 = ...;
int c[Orders][Orders] = ...;
int cc[Temperatures][ProductionLines] = ...;
int B[Orders] = ...;

int X_pre[1..(numberOfOrders+2)*(numberOfOrders+2)*numberOfVehicles] = ...;
int X[m in 1..(numberOfOrders+2), p in 1..(numberOfOrders+2),s in 1..numberOfVehicles] =
 X_pre[s+(numberOfOrders+2)*(p-1)+(numberOfOrders+2)*numberOfVehicles*(m-1)];

float teta[Orders] = ...;
int t[Batches] = ...;
int D[Batches] = ...; //due time for producing batch k
int M = ...; //sufficiently large number
int g[Batches] = ...; // setup time for producing batck k after batch (k-1)

// these parameters below are requrired to handle with the sub sets 
int BatchOrder[Orders][Batches] = ...; //binary parameter to indate the assignment of an order to a batch
int BatchTemperature[Batches][Temperatures] = ...;
                                         
                               
//////////////////////////////DECISION VARIABLES////////////////////////////////////////////////
dvar boolean Y[Temperatures][ProductionLines];    
dvar boolean Z[Batches][ProductionLines];              
dvar float+  F[Batches][ProductionLines];  //Finishing time of producing batch k on line l
dvar float+  FF[Batches];                  //Finishing time of producing batch k
dvar float+  SC[ProductionLines];          //Setup Cost on line l

//////////////////////////////OBJECTIVE FUNCTION////////////////////////////////////////////////
minimize  W_1*sum(l in ProductionLines) SC[l] +
          W_2*sum(k in Batches, i in Orders: i!=1 && i !=(numberOfOrders+2)) (B[i] - FF[k])*teta[i]*BatchOrder[i][k] +   
          W_3*sum(v in Vehicles, i in Orders, ii in Orders : i !=1 && (ii !=numberOfOrders+2))
          c[ii][i];
          //c[ii][i]*X[ii][i][v]
          
subject to
{

forall(h in Temperatures, l in ProductionLines) SC[l] >= cc[h][l]*Y[h][l];      
forall(h in Temperatures, l in ProductionLines) sum(k in Batches) BatchTemperature[k][h]*Z[k][l] <= M*Y[h][l];  
forall(k in Batches) sum(l in ProductionLines) Z[k][l] == 1;
forall(k in Batches, l in ProductionLines:k>=2) F[k][l] >= F[k-1][l] + g[k] + t[k]*Z[k][l];
forall(k in Batches, l in ProductionLines) F[k][l] <= D[k] + M*(1-Z[k][l]);      
forall(k in Batches, l in ProductionLines) FF[k]   <= F[k][l] + M*(1-Z[k][l]);      
     
}
