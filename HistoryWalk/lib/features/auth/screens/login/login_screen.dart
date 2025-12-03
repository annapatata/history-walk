import 'package:historywalk/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:historywalk/common/styles/spacing_styles.dart';
import 'package:historywalk/utils/constants/text_strings.dart';
import 'package:historywalk/utils/constants/sizes.dart';

class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( //we want to make the screen scrollable for small screens
        child: Padding(
          padding: SpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              //title
              Text(AppTexts.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
              //form
              Form(child:Column(
                children: [
                  //Email
                  TextFormField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined) , labelText: "Email"),
                    ),
                    
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  
                  //Password
                  TextFormField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.password_outlined), 
                      labelText: "Password",
                      suffixIcon: Icon(Icons.remove_red_eye_rounded),
                      ),
                    ),
                  const SizedBox(height: AppSizes.spaceBtwItems / 2),

                  //Remember Me & Forget Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                    children: [
                      //Remember Me
                      Row(children: [
                        Checkbox(value: true, onChanged: (value){}),
                        const Text("Remember Me"),
                      ],),
                      
                      //Forget Button
                      TextButton(onPressed: (){}, child: const Text("Forget Password?")),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  //Sign In Button
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NavigationMenu()));},
                    child: Text("Let's Go!"))),
                ],
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}