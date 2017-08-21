function SetRoot 
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
	# set the root
	$treeview1.Nodes.Clear()
	$listbox1.Items.Clear()
    $folder = Get-Item $Path
	$node=New-Object System.Windows.Forms.TreeNode
	$node.Name=$folder.FullName
	$node.Text=$folder.Name
	$treeview1.Nodes.Add($node)
}

function GetCheckedNodes([System.Windows.Forms.TreeNodeCollection]$nodes)
{
    foreach($aNode in $nodes)
    {
        $myNode = [System.Windows.Forms.TreeNode]$aNode
        if ($myNode.Checked)
        {
            $listbox1.Items.Add($myNode.FullPath)
        }
        
        if ($myNode.Nodes.Count -ne 0)
        {
            GetCheckedNodes($myNode.Nodes);
        }
    }
}

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Treeview Test"
$objForm.Size = New-Object System.Drawing.Size(540,500)
$objForm.MinimizeBox = $True
$objForm.MaximizeBox = $False
$objForm.FormBorderStyle = "FixedDialog"
$objForm.StartPosition = "CenterScreen"

$treeview1 = New-Object System.Windows.Forms.TreeView
$treeview1.Location = New-Object System.Drawing.Size(5, 20) 
$treeview1.Size = New-Object System.Drawing.Size(250, 400) 
$treeview1.CheckBoxes = $true
$treeview1.FullRowSelect = $true
$treeview1.HotTracking = $true
$treeview1.Add_NodeMouseClick({
	$node=$_.Node
	if (-not $_.Node.IsExpanded)
    {
        if ($_.Node.Nodes.Count -eq 0)
        {
            $children = ([io.directoryinfo]$node.FullPath).GetDirectories()
            $children | ForEach-Object { 
	            $n = New-Object System.Windows.Forms.TreeNode
	            $n.Name = $_.FullName
	            $n.Text = $_.Name
	            $node.Nodes.Add($n)
            }
        }
		$_.Node.Expand()
	}
    else
    {
		$_.Node.Collapse()
	}
	$listbox1.Items.Clear()
	[array]$files = ([io.directoryinfo]$node.FullPath).GetFiles()
	$listbox1.Items.AddRange($files)
})

$objForm.Controls.Add($treeview1) 

$listbox1 = New-Object System.Windows.Forms.ListBox
$listbox1.Location = New-Object System.Drawing.Size(260, 20) 
$listbox1.Size = New-Object System.Drawing.Size(250, 406) 
$objForm.Add_Load({
    SetRoot -Path "C:\"
})
$objForm.Controls.Add($listbox1)

#region OK Button
$OkButton = New-Object System.Windows.Forms.Button
$OkButton.Location = New-Object System.Drawing.Size(230,440)
$OkButton.Size = New-Object System.Drawing.Size(75,23)
$OkButton.Text = "Ok"

#region Code to check which nodes are checked
$OkButton.Add_Click({
    $listbox1.Items.Clear()
    GetCheckedNodes($treeview1.Nodes)
})
#endregion
$objForm.Controls.Add($OkButton)

[void] $objForm.ShowDialog()