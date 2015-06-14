########### SETUP
$app_name = "diullei-atom"
$app_path = "$HOME\.atom" 
$repo_uri = "https://github.com/diullei/diullei-atom.git" 
$repo_branch = "master"

########### SETUP FUNCTIONS

function msg 
{
    Write-Host $args
}

function success 
{
	msg "[Ok] $args"
}

function error
{
	msg "[Err!] $args"
    exit 1
}

function program_exists
{
	if (!(Get-Command $args[0] -ErrorAction SilentlyContinue))
	{ 
	    error "you must have $args installed to continue."
	} 
}

function do_backup
{
	msg "Attemping to back up your original atom configuration."
	$today = Get-Date -format yyyyMd_Hms
	Rename-Item -path $args[0] -newName "$args.$today"
	success "Your original atom cconfiguration has been backed up."
}

function sync_repo
{
	msg "Trying to update $app_path"
	
	if(Test-Path -Path $app_path)
	{
		cd $app_path
		git pull origin $repo_branch
		success "Successfully updated $app_path"
	}
	else
	{
		git clone -b $repo_branch $repo_uri $app_path
		success "Successfully cloned $app_path"
	}
}

function install_packages
{
	msg "Trying to install atom packages"
	apm install --packages-file "$app_path\package-list.txt"
	success "Successfully. All packages has been installed"
}

############################# MAIN()
program_exists "atom.cmd"
program_exists "apm.cmd"
program_exists "git.exe"

do_backup $app_path

sync_repo

install_packages

$today = Get-Date -format yyyy
msg "\nThanks for installing $app_name."
msg "© $today https://github.com/diullei/diullei-atom"
