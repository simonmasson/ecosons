## Copyright (C) 2013 Daniel Rodríguez Pérez
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

% ec_install:
% Menu driven installer and updater script for ecosons


%source folder and zip/tar package format
ec_repo='http://www.kartenn.es/wp-content/uploads/ecosons';
if( ispc() )
 ec_package='zip';
else
 ec_package='tar';
endif

%utils for WinXP
function ensureXPutils()
 if( length(glob('vbget.vbs'))==0 )
  f=fopen('vbget.vbs', 'wt');
   fprintf(f, 'Rem VBGet utility (wget replacement)\n');
   fprintf(f, 'Rem for XP Visual Basic Script\n');
   fprintf(f, 'Rem (c) DRP 2013\n');
   fprintf(f, 'If Wscript.Arguments.Count = 2 Then\n');
   fprintf(f, ' URL=Wscript.Arguments(0)\n');
   fprintf(f, ' FILE=Wscript.Arguments(1)\n');
   fprintf(f, ' Set HTTP=CreateObject("MSXML2.XMLHTTP")\n');
   fprintf(f, ' HTTP.open "GET", URL, False\n');
   fprintf(f, ' HTTP.send()\n');
   fprintf(f, ' If HTTP.Status = 200 Then\n');
   fprintf(f, '  Set writer=CreateObject("ADODB.Stream")\n');
   fprintf(f, '   writer.Open\n');
   fprintf(f, '   writer.Type=1\n');
   fprintf(f, '   writer.Write HTTP.ResponseBody\n');
   fprintf(f, '   writer.Position=0\n');
   fprintf(f, '   writer.SaveToFile FILE\n');
   fprintf(f, '   writer.Close\n');
   fprintf(f, ' Else\n');
   fprintf(f, '  MsgBox "Error: connection"\n');
   fprintf(f, ' End If\n');
   fprintf(f, ' Set HTTP=Nothing\n');
   fprintf(f, 'Else\n');
   fprintf(f, ' MsgBox "Error: 2 arguments (URL, FILE) required"\n');
   fprintf(f, 'End If\n');
  fclose(f);
 endif
 if( length(glob('vbunzip.vbs'))==0 )
  f=fopen('vbunzip.vbs', 'wt');
   fprintf(f, 'Rem VBUnzip utility (unzip replacement)\n');
   fprintf(f, 'Rem for XP Visual Basic Script\n');
   fprintf(f, 'Rem (c) DRP 2013\n');
   fprintf(f, 'If Wscript.Arguments.Count = 2 Then\n');
   fprintf(f, ' ZIP=Wscript.Arguments(0)\n');
   fprintf(f, ' DEST=Wscript.Arguments(1)\n');
   fprintf(f, ' Set FSO=CreateObject("Scripting.FileSystemObject")\n');
   fprintf(f, '  ZIP=FSO.GetAbsolutePathName(ZIP)\n');
   fprintf(f, '  DEST=FSO.GetAbsolutePathName(DEST)\n');
   fprintf(f, ' Set SHELL=CreateObject("Shell.Application")\n');
   fprintf(f, ' Set files=SHELL.NameSpace(ZIP).items\n');
   fprintf(f, ' If files.Count = 0 Then\n');
   fprintf(f, '  MsgBox "Error: invalid ZIP"\n');
   fprintf(f, ' Else\n');
   fprintf(f, '  SHELL.NameSpace(DEST).CopyHere(files)\n');
   fprintf(f, ' End If\n');
   fprintf(f, 'Else\n');
   fprintf(f, ' MsgBox "Error: 2 arguments (ZIP, DESTINATION) required"\n');
   fprintf(f, 'End If\n');

  fclose(f); 
 endif

endfunction


%system dependent function to download
function err=getURL(url, file)
 err=1;

 if( ispc() )
  % power shell file download
  err=system(['PowerShell -command "(new-object System.Net.WebClient).DownloadFile(' '''' url '''' ', ' '''' file '''' ')']);
  if( err )
   % try old XP windows
   ensureXPutils();
   err=system(['cscript.exe vbget.vbs "' url '" "' file '"']);
  endif
 endif
 if( isunix() )
  err=system(['wget "' url '" -O "' file '"']);
 endif
 if( ismac() )
  err=system(['curl "' url '" -o "' file '"']);
 endif
 
endfunction

%system dependent file extraction function
function err=extractZIP(z)
 err=1;
 if( index(z, '.zip')>0 )
  if( ispc() )
   %power shell Windows copy from compressed folder
   err=system(['PowerShell -command "$sa=new-object -com shell.application; $zf=$sa.namespace((Get-Location).Path + ' '''' '\' z '''' '); $ds=$sa.namespace((Get-Location).Path); $ds.Copyhere($zf.items())"']);
   
   if( err )
    % try old XP windows
    ensureXPutils();
    err=system(['cscript.exe vbunzip.vbs "' z '" .']);
   endif
   
  else
   err=system(['unzip "' z '"']);
  endif
  
 endif
 if( index(z, '.tar')>0 )
  err=system(['tar xf "' z '"']);
 endif

endfunction


%updates and new installation candidates
update_list={};
install_list={};

%download file listing
err=getURL([ec_repo filesep 'list.txt'], 'new_list.txt');
if( ~err )

 %read file listing
 f=fopen('new_list.txt', 'r');
 while( ~feof(f) )
  s=fgets(f);
  
  %available application and version
  ss=strsplit(s, "\t");
  new_app=ss{1};
  new_ver=str2num(ss{2});
  
  %check if already installed
  gn=glob( [new_app filesep 'version.txt'] );
  if( length(gn)==1 )

   %get installed version
   g=fopen(gn{1}, 'r');
   s=fgets(g);
   fclose(g);
   
   ss=strsplit(s, "\t");
   cur_app=ss{1};
   cur_ver=str2num(ss{2});
  
   %if a newer version is available check for update
   if( new_ver > cur_ver )
    update_list{end+1}=new_app;
   endif
  
  else

   %not yet installed, check for install
   install_list{end+1}=new_app;
  
  endif

 endwhile

 fclose(f);
 delete('new_list.txt');

else
 disp(['Error: unable to connect to ' ec_repo]);
endif


%install
del_package=true;
del_package_swmsg='Keep packages';
while( length(install_list) > 0 )

 opt=menu('Installable applications:', install_list{:}, del_package_swmsg, 'Skip install');
 
 %package storage policy
 if(opt==length(install_list)+1)
  del_package=~del_package;
  if(del_package)
   del_package_swmsg='Keep packages';
  else
   del_package_swmsg='Remove packages';
  endif
 endif

 %skip install
 if(opt==length(install_list)+2)
  break;
 endif

 %install package
 if(opt<=length(install_list))
  fn=[install_list{opt} '.' ec_package];
  err=getURL([ec_repo '/' fn ], fn);
  if( ~err )
  
   err=extractZIP(fn);
   if( ~err )
    install_list={install_list{1:opt-1} install_list{opt+1:end}};
    
    if( del_package )
     delete(fn);
    endif
    
   else
    disp('Error extracting package');
   endif
  
  else
   disp('Error downloading package');
  endif
 endif
endwhile


%update
while( length(update_list) > 0 )

 opt=menu('Updates available:', update_list{:}, del_package_swmsg, 'Skip update');

 %package storage policy
 if(opt==length(update_list)+1)
  del_package=~del_package;
  if(del_package)
   del_package_swmsg='Keep packages';
  else
   del_package_swmsg='Remove packages';
  endif
 endif

 %skip update
 if(opt==length(update_list)+2)
  break;
 endif
 if(opt<=length(update_list))
  fn=[update_list{opt} '.' ec_package];
  err=getURL([ec_repo '/' fn ], fn);
  if( ~err )
  
   err=extractZIP(fn);
   if( ~err )
    update_list={update_list{1:opt-1} update_list{opt+1:end}};

    if( del_package )
     delete(fn);
    endif

   else
    disp('Error extracting package');
   endif
  
  else
   disp('Error downloading package');
  endif
 endif
endwhile


%create ec_config.m
app_versions=glob([ pwd() filesep '*' filesep 'version.txt']);
f=fopen('ec_config.m', 'w');
fprintf(f, '%%value=ec_config(key)\n');
fprintf(f, '%%ecosons configuration parameters\n');
fprintf(f, '%%current key can be: path (of installation), version\n');
fprintf(f, '%%returns the value of the key\n');
fprintf(f, 'function value=ec_config(key)\n');
fprintf(f, ' switch(key)\n');
fprintf(f, "  case 'path'\n");
fprintf(f, "   value='%s';\n", pwd());
for n=1:length(app_versions)
 g=fopen(app_versions{n}, 'r');
  s=fgets(g);
 fclose(g);
  ss=strsplit(s, "\t");
 if( ~strcmp(ss{1}, 'ecosons_lib') )
  fprintf(f, "  case 'ecosons_version'\n   value='%d'", str2num(ss{2}));
 else
  fprintf(f, "  case '%s_version'\n   value='%d'\n", ss{1}, str2num(ss{2}));
 endif
endfor
fprintf(f, ' endswitch\n');
fprintf(f, 'endfunction\n');
fclose(f);

%always try to download launcher
err=getURL([ec_repo filesep 'ecosons.m'], 'ecosons.m');

%start ecosons launcher
if( length( glob('ecosons.m') ) > 0 )
 ecosons
else
 disp('Error: unable to start ecosons');
endif
