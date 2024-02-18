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

%ecosons:
% Launcher of the chosen ecosons application

%clear all variables
%clear all
global SONAR_DATA;

%get ecosons file directory
ec_dir=strrep(mfilename('fullpathext'), 'ecosons.m', '');

%remove ecosons dirs from path
pth=strsplit(path(), pathsep());
rmpth=ec_dir(1:end-1); %remove trailing path separator
for n=2:length(pth)
 if( index(pth{n}, rmpth)>0 )
  rmpath(pth{n})
 endif
endfor

%build application menu
app_versions=glob([ec_dir '*' filesep 'version.txt']);
app_menu={};
for n=1:length(app_versions)
 f=fopen(app_versions{n}, 'r');
  s=fgets(f);
  ss=strsplit(s, "\t");
  if( ~strcmp(ss{1}, 'ecosons_lib') )
   app_menu{end+1}=ss{1};
  endif
 fclose(f);
endfor

%set library path
addpath(ec_dir);
addpath([ec_dir 'ecosons_lib' filesep 'utils']);
addpath([ec_dir 'ecosons_lib' filesep 'procs']);
addpath([ec_dir 'ecosons_lib' filesep 'formats']);

%choose application
opt=menu('Choose ecosons application:', app_menu{:}, 'Quit');
if( opt<=length(app_menu) )
 ec_app=app_menu{opt};

 %set application path
 addpath([ec_dir ec_app filesep]);
 addpath([ec_dir ec_app filesep 'utils']);
 addpath([ec_dir ec_app filesep 'procs']);
 %addpath([ec_dir ec_app filesep 'formats']);

 %run application's ec
 disp('Calling ecosons application as:');
 disp(' ec');
 ec
 
else
 return;
endif
