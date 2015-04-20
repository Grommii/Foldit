# Foldit-Constructor-script
Greetings!

It is a script that contains many other scripts and allows you to run any of them. Just choose which one to run after the start.
Also there is an Autobot script that allows you to predefine the run sequence of basic scripts with given parameters. So you can create your own Score gain algorithm.

How it works:
1. Each basic script have a code and some of them have a parameters. When you want to include a basic script to sequence, print code and print all the parameters with the underscore. After the each basic script print the dot.
For example, if you want to use BlueFuze just include "BF." in the sequence. If you want to use Band Test include "BT_15_87_97.", where 15, 87 and 97 - script parameters (see description).
2. When sequence is completed, write it to text field and start the script.
3. Script will be sequentially running your predefined scripts. When All scripts completed, it checks how much score is gained. If its exceed the limit (limit can be set to 0), then the sequence runs for one more time. If not, then the Iterations ends and the new Iteration starts (from the structure when the script was started).

The example of sequence, that I use:
Default:        "CL.FR.BT_15_87_97.BT_15_103_113.RW_2_1_10.QU_15.BF.RW_1_1_10.LW_12_2.SR."
For Mutable:    "CL.FR.BT_10_87_97.MT_3_20.BT_10_103_113.NM.RW_2_1_10.MT_3_20.QU_15.BF.RW_1_1_10.LW_12_2.SR."
For Multistart: "WS.BT_2_87_97.FR.CL.BT_10_87_97.BT_10_103_113.RW_2_1_10.QU_15.BF.RW_1_1_10.LW_12_2.SR."

Basic scripts.

1. Clashing.
Script code: CL
Script Parameters: none
Script Description: Making a sequence of wiggles and shakes with different clashing.

2. FastRelax.
Script code: FR
Script Parameters: none
Script Description: Well known FastRelax script :)

3. BlueFuze.
Script code: BF
Script Parameters: none
Script Description: BlueFuze.

4. WS or SW. 
Script code: WS
Script Parameters: none
Script Description: Tries 4 different WS/SW tactics to improve score from destabilized status.

5. Band Test.
Script code: BT
Script Parameters:
1) Number of iterations.
2) Lowest length (in % from original).
3) Highest length (in % from original).
Script Description: Creates a random band with the length in given boundaries. Wiggle structure with band enabled, then delete band and wiggle out. Repeat given number of Iterations.
Script example: "BT_15_87_97.".

6. Local Wiggle.
Script code: LW
Script Parameters:
1) Wiggle segment Length
2) Number of wiggle iterations.
Script Description: Makes local wiggle.
Script example: "LW_12_2.".

7. Local Rebuild.
Script code: LR
Script Parameters:
1) Rebuild segment Length
Script Description: Makes local rebuildes from the begin to the end of structure.
Script example: "LW_12_2.".

8. Quake.
Script code: QU
Script Parameters:
1) Distance between segments with bands.
Script Description: Makes bands with the given length between segments. Wiggle structure with band enabled, then delete band and wiggle out.
Script example: "QU_15.".

9. Sidechain Test.
Script code: ST
Script Parameters:
1) Number of segments
Script Description: Test every possible position of sidechain at given number of random segments.
Script example: "ST_10.".

10. Mutate.
Script code: MU
Script Parameters: none
Script Description: Just do mutate once.

11. Mutate and Test.
Script code: MT
Script Parameters: 
1) Function number.
2) Number of tries (affects only 3rd function).
Script Description:
 Depending on the function number it does: 
 1) Test all posible changes of AA for one segment (very long).
 2) Test all posible changes of AA for two segment (impossible long).
 3) Test random change of 2 AAs for given number of times.
Script example: "MT_3_10.".

12. New Mutate
Script code: NM
Script Parameters: none
Script Description: Sequentially mutate each segment for all possible AAs.

13. Rebuilder
Script code: RE
Script Parameters: 
1) Start segment.
2) End segment.
3) Number of tries.
Script Description: Rebuild the segment and check the structure by wiggles and shake.
Script example: "RE_10_13_5.".

14. Sidechain Flipper.
Script code: SF
Script Parameters: none
Script Description: Sequentially flips each sidechain.

15. Soft Relax
Script code: SR
Script Parameters: none
Script Description: The variation of FastRelax.

16. Rebuild Worst.
Script code: RW
Script Parameters: 
1) Length of segment to rebuild.
2) Number of tries for each segment.
3) Number of segments to rebuild.
Script Description: Rebuilds the worst scoring segments of given length.
Script example: "RW_1_1_10.".

17. MicroIdealize
Script code: MI
Script Parameters: 
1) Length of segment to Idealize.
2) Number of segments to Idealize.
Script Description: Idealizes the worst scoring segments (idealize score) of given length.
Script example: "MI_3_4.".
