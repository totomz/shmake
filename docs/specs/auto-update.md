# Context 
Users download the shMakefile scripts and have a separated copy. 
It would be nice to have a system tha auto-update the shMakefile and functions.sh scripts 

# Requirements
- The function to check for upgrade is executed manually - we don't want to throw an http request for a 50 lines bash script
- This change should not bring in any dependence - just relies on `curl` and silently skip the check if `curl` is missing
- There is no release versioning / release number, because we assume that  every commit is a new version and that there will be NEVER breaking changes
- The function should do a diff of functions.sh, return "new version" if there are differences
- The function should diff shMakefile but only the lines before `# ---- safe edit from here ---` and after `# ---- safe edit STOP here ---`
- If there are new changes, ask the user to apply the diff. Replace the functions.sh,  or update shMakefile but only the lines before `# ---- safe edit from here ---` and after `# ---- safe edit STOP here ---`