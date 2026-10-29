"""Generates a minimal .dproj (RAD Studio 11+) for a console .dpr.

usage: python scripts/gen_dproj.py <project.dpr> <Win32|Win64> [extra search path]
"""
import re, sys, uuid, pathlib

dpr = pathlib.Path(sys.argv[1])
platform = sys.argv[2]
search = sys.argv[3] if len(sys.argv) > 3 else ''
name = dpr.stem
src = dpr.read_text(encoding='utf-8-sig')
refs = re.findall(r"in\s+'([^']+\.pas)'", src)
refs_xml = '\n'.join(f'        <DCCReference Include="{r}"/>' for r in refs)
targets = {'Win32': 1, 'Win64': 2}[platform]
xml = rf'''<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <PropertyGroup>
        <ProjectGuid>{{{str(uuid.uuid5(uuid.NAMESPACE_URL, name)).upper()}}}</ProjectGuid>
        <ProjectVersion>19.5</ProjectVersion>
        <FrameworkType>None</FrameworkType>
        <AppType>Console</AppType>
        <MainSource>{dpr.name}</MainSource>
        <Base>True</Base>
        <Config Condition="'$(Config)'==''">Debug</Config>
        <Platform Condition="'$(Platform)'==''">{platform}</Platform>
        <TargetedPlatforms>{targets}</TargetedPlatforms>
    </PropertyGroup>
    <PropertyGroup Condition="'$(Config)'=='Base' or '$(Base)'!=''">
        <Base>true</Base>
    </PropertyGroup>
    <PropertyGroup Condition="('$(Platform)'=='{platform}' and '$(Base)'=='true') or '$(Base_{platform})'!=''">
        <Base_{platform}>true</Base_{platform}>
        <CfgParent>Base</CfgParent>
        <Base>true</Base>
    </PropertyGroup>
    <PropertyGroup Condition="'$(Config)'=='Debug' or '$(Cfg_1)'!=''">
        <Cfg_1>true</Cfg_1>
        <CfgParent>Base</CfgParent>
        <Base>true</Base>
    </PropertyGroup>
    <PropertyGroup Condition="'$(Base)'!=''">
        <SanitizedProjectName>{name}</SanitizedProjectName>
        <DCC_DcuOutput>.\$(Platform)\$(Config)\dcu</DCC_DcuOutput>
        <DCC_ExeOutput>.\$(Platform)\$(Config)</DCC_ExeOutput>
        <DCC_UnitSearchPath>{search};$(DCC_UnitSearchPath)</DCC_UnitSearchPath>
        <DCC_E>false</DCC_E>
        <DCC_N>false</DCC_N>
        <DCC_S>false</DCC_S>
        <DCC_F>false</DCC_F>
        <DCC_K>false</DCC_K>
        <DCC_Namespace>System;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;$(DCC_Namespace)</DCC_Namespace>
    </PropertyGroup>
    <PropertyGroup Condition="'$(Cfg_1)'!=''">
        <DCC_Define>DEBUG;$(DCC_Define)</DCC_Define>
        <DCC_Optimize>false</DCC_Optimize>
        <DCC_GenerateStackFrames>true</DCC_GenerateStackFrames>
    </PropertyGroup>
    <ItemGroup>
        <DelphiCompile Include="$(MainSource)">
            <MainSource>MainSource</MainSource>
        </DelphiCompile>
{refs_xml}
        <BuildConfiguration Include="Base">
            <Key>Base</Key>
        </BuildConfiguration>
        <BuildConfiguration Include="Debug">
            <Key>Cfg_1</Key>
            <CfgParent>Base</CfgParent>
        </BuildConfiguration>
    </ItemGroup>
    <ProjectExtensions>
        <Borland.Personality>Delphi.Personality.12</Borland.Personality>
        <Borland.ProjectType>Application</Borland.ProjectType>
        <BorlandProject>
            <Delphi.Personality>
                <Source>
                    <Source Name="MainSource">{dpr.name}</Source>
                </Source>
            </Delphi.Personality>
            <Platforms>
                <Platform value="{platform}">True</Platform>
            </Platforms>
        </BorlandProject>
        <ProjectFileVersion>12</ProjectFileVersion>
    </ProjectExtensions>
    <Import Project="$(BDS)\Bin\CodeGear.Delphi.Targets" Condition="Exists('$(BDS)\Bin\CodeGear.Delphi.Targets')"/>
</Project>
'''
out = dpr.with_suffix('.dproj')
out.write_text(xml, encoding='utf-8')
print('wrote', out)
