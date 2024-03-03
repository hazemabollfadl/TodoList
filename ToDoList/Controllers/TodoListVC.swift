import UIKit

class TodoListVC: UITableViewController  {
    
    let defaults = UserDefaults.standard
    
    var itemArray:[Items]=[
        Items(name: "A", done: false),
        Items(name: "B", done: false),
        Items(name: "C", done: false)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let safeItemArray=defaults.array(forKey: "TodoListArray") as? [String]{
            itemArray=safeItemArray
        }
    }
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textResult = UITextField()
        
        let alert=UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert )
        
        let action=UIAlertAction(title: "Add Item", style: .default) { action in
            
            //what happens when the user clicks add item
            if textResult.text==""{
                let alert=UIAlertController(title: "Warning", message: "No Items Were Added", preferredStyle: .alert)
                let action=UIAlertAction(title: "Ok", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }else{
                //stores added item in the array of itemArray
                self.itemArray.append(textResult.text!)
                
                //set the appended item in the itemarray to User defaults using the default object created above
                self.defaults.set(self.itemArray, forKey: "TodoListArray")
                
                //Reloads the tableView
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        alert.addTextField { alertTextField in
            alertTextField.placeholder="Create New Item"
            textResult=alertTextField
        }
        
        present(alert, animated: true)
    }
}

//MARK: - UITableViewDataSources
extension TodoListVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemList = itemArray[indexPath.row].name
        
        //let cell=tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell")!
        let cell=UITableViewCell(style: .default , reuseIdentifier: "ToDoItemCell")
        
        
        cell.textLabel?.text=itemList
        
        return cell
        
    }
    
}

//MARK: - UITableViewDelegate
extension TodoListVC{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark){
            itemArray[indexPath.row].done=false
        }else{
            itemArray[indexPath.row].done=true
        }
        
        if itemArray[indexPath.row].done == false{
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

 
