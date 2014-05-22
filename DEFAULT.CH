*===========================================================
* File Name   | DEFAULT.CH
* Description | Commands for providing default values.
* Author      | Greg Holmes, gregh@ghservices.com
*===========================================================

#ifndef _DEFAULT_CH_
#define _DEFAULT_CH_

#xcommand DEFAULT <v> TO <x> [, <vn> TO <xn>]  => ;
          if <v> == NIL ; <v> := <x> ; end        ;
          [ ; if <vn> == NIL ; <vn> := <xn> ; end]

#xcommand DEFAULT ARRAY      <v> TO <x>      => ;
          if .not. (valtype(<v>) == 'A') ; <v> := <x> ; end

#xcommand DEFAULT BLOCK      <v> TO <x>      => ;
          if .not. (valtype(<v>) == 'B') ; <v> := <x> ; end

#xcommand DEFAULT CODE BLOCK <v> TO <x>      => ;
          if .not. (valtype(<v>) == 'B') ; <v> := <x> ; end

#xcommand DEFAULT CODEBLOCK  <v> TO <x>      => ;
          if .not. (valtype(<v>) == 'B') ; <v> := <x> ; end

#xcommand DEFAULT CHARACTER  <v> TO <x>      => ;
          if .not. (valtype(<v>) == 'C') ; <v> := <x> ; end

#xcommand DEFAULT STRING     <v> TO <x>      => ;
          if .not. (valtype(<v>) $ 'CM') ; <v> := <x> ; end

#xcommand DEFAULT DATE       <v> TO <x>      => ;
          if .not. (valtype(<v>) == 'D') ; <v> := <x> ; end

#xcommand DEFAULT LOGICAL    <v> TO <x>      => ;
          if .not. (valtype(<v>) == 'L') ; <v> := <x> ; end

#xcommand DEFAULT MEMO       <v> TO <x>      => ;
          if .not. (valtype(<v>) == 'M') ; <v> := <x> ; end

#xcommand DEFAULT NUMBER     <v> TO <x>      => ;
          if .not. (valtype(<v>) == 'N') ; <v> := <x> ; end

#xcommand DEFAULT NUMERIC    <v> TO <x>      => ;
          if .not. (valtype(<v>) == 'N') ; <v> := <x> ; end

#endif