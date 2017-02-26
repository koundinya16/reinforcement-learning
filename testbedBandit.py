# Author : Koundinya

""" 
10 armed bandit test bed with epsilon-greedy action selection and sample averages for action-value estimates 

---> Plots average reward vs number of iterations/plays
---> Plots % of time optimal action was selected

"""

# Mindfuck : calling generateNewBandit() for generating new(random) valueFunction_true fucks up the graphs, but directly
#            pasting the function code inside the loop does not cause any problems

from __future__ import print_function
import numpy as np 
import multiprocessing
import matplotlib.pyplot as plt

class Bandit:


	 
	def __init__(self,arms=10,plays=1000,runs=1000,policy=None,parameter=0):
		self.num_of_arms=arms
		self.num_of_plays=plays
		self.num_of_runs=runs
		self.policy=policy
		self.parameter=parameter


	def simulate(self):
		# num_of_arms=10

		# Number of times a n-armed bandit/slot-machine is to be played
		# num_of_plays

		# Number of  different n-armed bandits to be generated/considered
		# num_of_runs


		# Exploration parameter e
		# e=0.1

		# Temperature parameter t
		# t=0.02

		# UCB

		# Value function Estimate for all the runs
		valueFunction_estimate=np.zeros((self.num_of_runs,self.num_of_arms))

		# True/final Values of action(to which value function converges to) for each run
		valueFunction_true=np.zeros((self.num_of_runs,self.num_of_arms))

		# Array to store the number of times an action was selected, and the cumulative reward it received
		info_action=np.zeros((self.num_of_runs,2,self.num_of_arms))

		# Reward received for each action over all plays for all the different bandits
		reward=np.zeros((self.num_of_runs,self.num_of_plays))

		avgReward=np.zeros((self.num_of_plays))
		
		# Number of times optimal action is selected
		optimalActionCount=0
		optimalAction=np.zeros((self.num_of_runs,self.num_of_plays))

		# % optimal action an average over all runs
		avgOptimalAction=np.zeros((self.num_of_plays))
        
        p=multiprocessing.Pool(processes=4)

		if(self.policy=="egreedy"):
			def takeAction():
				return epsilonGreedy()
		elif(self.policy=="softmax"):
			def takeAction():
				return softmax()
		elif(self.policy=="ucb"):
			def takeAction():
				return ucb()


		# epsilon-greedy policy for action selection
		def epsilonGreedy():
			if(np.random.randint(1,100) <= 100*self.parameter):	
				action=np.random.randint(0,self.num_of_arms-1)  # random action with probability e
			else:
				action=np.argmax(valueFunction_estimate[current_run]) # greedy action with probability 1-e
			
			return action
        
        # Upper Confidence Bound based action selection rule
		def ucb():
			ucb_array=np.zeros((self.num_of_arms))
			ucb_array=np.multiply(self.parameter,np.sqrt(np.divide(np.log(current_play),info_action[current_run][1])))
			
			action=np.argmax(np.add(valueFunction_estimate[current_run],ucb_array))
			return action

		# Softmax action selection policy
		def softmax():
			action_prob=np.exp(np.divide(valueFunction_estimate[current_run],self.parameter))/np.sum(np.exp(np.divide(valueFunction_estimate[current_run],self.parameter)),axis=0)
			action=np.random.choice(self.num_of_arms,p=action_prob)
			
			return action
		
		
		# Get a reward for a given action ~ N(Q*,1)
		def getReward(action):
			rwrd=np.random.normal(valueFunction_true[current_run][action],1)
			return rwrd

		# Generate true action-value function values[Q*] for a new n-armed bandit randomly ~ N(0,1)
		def generateNewBandit():
			valueFunction_true[current_run]=np.random.normal(0,1,self.num_of_arms)	
			return

		# Update the value function estimate [Q] using sample average method : over long iterations Q--->Q* 
		def updateValueFunction(rwrd,action):
			info_action[current_run][1][action]+=1
			info_action[current_run][0][action]+=rwrd
			valueFunction_estimate[current_run][action]=(info_action[current_run][0][action])/(info_action[current_run][1][action])
			return

		print("Starting bandit test bed with---",self.policy,"----policy (",self.parameter,")")
		
		# Generate true value function values[Q*] for all the bandits randomly~N(0,1)
		for i in range(0,self.num_of_runs):
			valueFunction_true[i]=np.random.normal(0,1,self.num_of_arms)
		a=0

		# Initialization for UCB1 policy : pull all arms once
		if(self.policy=="ucb"):
			a=self.num_of_arms
			for j in range(0,self.num_of_runs):
				for i in range(0,self.num_of_arms):
					reward[j][i]=np.random.normal(valueFunction_true[j][i],1)
					info_action[j][1][i]+=1
					info_action[j][0][i]+=reward[j][i]
					valueFunction_estimate[j][i]=(info_action[j][0][i])/(info_action[j][1][i])
			print("Done initializing : pull all arms once")
		

		# Simulate multiple n-armed bandits,each for a number of plays
		for current_run in range(0,self.num_of_runs):
			print("Run   :   ",current_run+1)
			bestAction=np.argmax(valueFunction_true[current_run])
			optimalActionCount=0
			for current_play in range(a,self.num_of_plays):
				print("\rPlay : ",current_play+1,end='')
				action=takeAction()
				reward[current_run][current_play]=getReward(action)
				if(action==bestAction):
					optimalActionCount+=1
					optimalAction[current_run][current_play]=optimalActionCount
				updateValueFunction(reward[current_run][current_play],action)
			print("\033[F",end='')

		# Calculate average reward at each play/step for all the bandits and percentage optimal action taken	
		for i in range(0,self.num_of_plays):
			for j in range(0,self.num_of_runs):
				avgReward[i]=avgReward[i]+reward[j][i]
				avgOptimalAction[i]+=optimalAction[j][i]
			avgReward[i]=avgReward[i]/self.num_of_runs
			avgOptimalAction[i]=avgOptimalAction[i]/self.num_of_runs
			avgOptimalAction[i]=(avgOptimalAction[i]/(i+1))*100 
		print("\n\nDone")

		return avgReward,avgOptimalAction
        
		
		
#---------------------------Question 1 : Epsilon greedy policy with epsilon : 0.01,0.1,0---------------------
question_1_a=Bandit(parameter=0.1,plays=1000,runs=2000,policy="egreedy")
rwd1_1,optAct1_1=question_1_a.simulate()
question_1_b=Bandit(parameter=0.01,plays=1000,runs=2000,policy="egreedy")
rwd2_1,optAct2_1=question_1_b.simulate()
question_1_c=Bandit(parameter=0,plays=1000,runs=2000,policy="egreedy")
rwd3_1,optAct3_1=question_1_c.simulate()

plt.figure(1)
plt.title('$\epsilon$-Greedy')
plt.plot(rwd1_1,label='$\epsilon$ : 0.1')
plt.plot(rwd2_1,label='$\epsilon$ : 0.01')
plt.plot(rwd3_1,label='$\epsilon$ : 0')

plt.ylabel("Average Reward")
plt.xlabel("Plays/Steps")
plt.legend()
plt.savefig('1a.jpg')

plt.figure(2)
plt.title('$\epsilon$-Greedy')
plt.plot(optAct1_1,label='$\epsilon$ : 0.1')
plt.plot(optAct2_1,label='$\epsilon$ : 0.01')
plt.plot(optAct3_1,label='$\epsilon$ : 0')
	
plt.ylabel("% Optimal Action")
plt.xlabel("Plays/Steps")
plt.legend()
plt.savefig('1b.jpg')

#------------------------------Question 2 : Softmax policy with temperature(t): 1,0.1,0.01---------------
question_2_a=Bandit(parameter=1,plays=1000,runs=2000,policy="softmax")
rwd1_2,optAct1_2=question_2_a.simulate()
question_2_b=Bandit(parameter=0.1,plays=1000,runs=2000,policy="softmax")
rwd2_2,optAct2_2=question_2_b.simulate()
question_2_c=Bandit(parameter=0.01,plays=1000,runs=2000,policy="softmax")
rwd3_2,optAct3_2=question_2_c.simulate()

plt.figure(1)
plt.title('Softmax')
plt.plot(rwd1_2,label='$\Gamma$ : 1')
plt.plot(rwd2_2,label='$\Gamma$ : 0.1')
plt.plot(rwd3_2,label='$\Gamma$ : 0.01')

plt.ylabel("Average Reward")
plt.xlabel("Plays/Steps")
plt.legend()
plt.savefig('2a.jpg')

plt.figure(2)
plt.title('Softmax')
plt.plot(optAct1_2,label='$\Gamma$ : 1')
plt.plot(optAct2_2,label='$\Gamma$ : 0.1')
plt.plot(optAct3_2,label='$\Gamma$ : 0.01')
	
plt.ylabel("% Optimal Action")
plt.xlabel("Plays/Steps")
plt.legend()
plt.savefig('2b.jpg')

#----------------------------------Question 3 : UCB1 policy  with C:2,sqrt(2),0.5--------------------------
question_3_a=Bandit(parameter=0.5,plays=1000,runs=2000,policy="ucb")
rwd1_3,optAct1_3=question_3_a.simulate()
question_3_b=Bandit(parameter=np.sqrt(2),plays=1000,runs=2000,policy="ucb")
rwd2_3,optAct2_3=question_3_b.simulate()
question_3_c=Bandit(parameter=2,plays=1000,runs=2000,policy="ucb")
rwd3_3,optAct3_3=question_3_c.simulate()

plt.figure(1)
plt.title('UCB1')
plt.plot(rwd1_3,label='C : 0.5')
plt.plot(rwd2_3,label='C : $\sqrt{2}$')
plt.plot(rwd3_3,label='C : 2')

plt.ylabel("Average Reward")
plt.xlabel("Plays/Steps")
plt.legend()
plt.savefig('3a.jpg')

plt.figure(2)
plt.title('UCB1')
plt.plot(optAct1_3,label='C : 0.5')
plt.plot(optAct2_3,label='C : $\sqrt{2}$')
plt.plot(optAct3_3,label='C : 2')
	
plt.ylabel("% Optimal Action")
plt.xlabel("Plays/Steps")
plt.legend()
plt.savefig('3b.jpg')

# --------------------------Question 4 : UCB1 policy with 1000-armed bandit for C : 0.1,sqrt(2),2---------------
question_4_a=Bandit(arms=1000,parameter=0.1,plays=3000,runs=2000,policy="ucb")
rwd1_4,optAct1_4=question_4_a.simulate()
question_4_b=Bandit(arms=1000,parameter=1.414,plays=3000,runs=2000,policy="ucb")
rwd2_4,optAct2_4=question_4_b.simulate()
question_4_c=Bandit(arms=1000,parameter=2,plays=3000,runs=2000,policy="ucb")
rwd3_4,optAct3_4=question_4_c.simulate()

plt.figure(1)
plt.title('UCB1-1000 armed bandit')
plt.plot(rwd1_4,label='C : 0.1')
plt.plot(rwd2_4,label='C : $\sqrt{2}$')
plt.plot(rwd3_4,label='C : 2')

plt.ylabel("Average Reward")
plt.xlabel("Plays/Steps")
plt.legend()
plt.savefig('4a.jpg')

plt.figure(2)
plt.title('UCB1-1000 armed bandit')
plt.plot(optAct1_4,label='C : 0.1')
plt.plot(optAct2_4,label='C : $\sqrt{2}$')
plt.plot(optAct3_4,label='C : 2')
	
plt.ylabel("% Optimal Action")
plt.xlabel("Plays")
plt.legend()
plt.savefig('4b.jpg')

plt.show()