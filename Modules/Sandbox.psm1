function Get-RedditUserPatternCount
{
    <#
        .SYNOPSIS
        Get a count of how many times a reddit user has said a pattern in their posts/comments.

        .PARAMETER Username
        The reddit username to check.

        .PARAMETER  Pattern
        The pattern to search within the reddit user's content.

        .PARAMETER PostCount
        The number of posts to check.

        .EXAMPLE
        PS C:\> Get-RedditUserPatternCount 
        Will clear all variables and modules from the current console session.

        .EXAMPLE
        PS C:\> Get-RedditUserPatternCount -Username reddit_user -Pattern "*lol*"
        See how many times reddit_user has repeated the pattern "lol" in their posts.

        .NOTES
        NAME        :  Get-RedditUserPatternCount
        VERSION     :  1.0   
        LAST UPDATED:  17/08/2017
        AUTHOR      :  Michael Metcalfe
        .INPUTS
        None
        .OUTPUTS
        None
    #>
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        [string]$Pattern = "*grin*",
        [int]$PostCount='25'
    )

    $posts = ([XML](Invoke-WebRequest https://www.reddit.com/user/$Username.xml?limit=$PostCount).content).feed.entry
    foreach ($post in $posts) {
        $Found += (($post.content.'#text').split() | ?{$_ -like "$Pattern"}).count
    }

    [pscustomobject]@{
    'Pattern: ' = $Pattern
    'Posts counted:' = $posts.count
    'Total found patterns:' = $Found
    'Average pattern/post:' = $Found / $posts.count
    }
}

Export-ModuleMember -Function *