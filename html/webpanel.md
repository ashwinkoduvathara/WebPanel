To Display username   
                              
                              <?php
                            // Use shell command to fetch the machine name
                            $machineName = trim(shell_exec('hostname'));
                            
                            // Display the machine name on the web page
                            ?>
                        
                          <h5 class="card-title text-primary"> <?php echo $machineName ?> </h5>
                          
